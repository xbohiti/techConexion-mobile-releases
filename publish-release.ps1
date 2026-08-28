# Publishes one or more APKs as a GitHub release in this repo.
# Usage:
#   .\publish-release.ps1 -Version 1.0.2 -ApkPaths "C:\path\to\app-arm64.apk","C:\path\to\app-armeabi.apk"
# Requires: git credential (GitHub) already stored - i.e. you have pushed to GitHub from this machine before.
param(
    [Parameter(Mandatory = $true)][string]$Version,
    [Parameter(Mandatory = $true)][string[]]$ApkPaths,
    [string]$Owner = "xbohiti",
    [string]$Repo = "techConexion-mobile-releases"
)

$ErrorActionPreference = "Stop"

# Allow comma-separated string when invoked via: powershell -File publish-release.ps1 -ApkPaths "a,b"
if ($ApkPaths.Count -eq 1 -and $ApkPaths[0] -match ",") { $ApkPaths = $ApkPaths[0] -split "," | ForEach-Object { $_.Trim() } }

$cred = "protocol=https`nhost=github.com`n" | git credential fill
$tok = ($cred | Select-String -Pattern '^password=(.+)$').Matches.Groups[1].Value
if (-not $tok) { throw "No GitHub credential found. Push to GitHub once from this machine first." }
$headers = @{ Authorization = "token $tok"; "User-Agent" = "publish-release-script" }

$tag = "v$Version"
$notes = New-Object System.Text.StringBuilder
[void]$notes.AppendLine("TechConexion mobile $tag")
[void]$notes.AppendLine("")
[void]$notes.AppendLine("SHA-256 checksums:")
[void]$notes.AppendLine("")
[void]$notes.AppendLine("| File | SHA-256 |")
[void]$notes.AppendLine("|---|---|")

foreach ($apk in $ApkPaths) {
    if (-not (Test-Path -LiteralPath $apk)) { throw "APK not found: $apk" }
    $hash = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash
    [void]$notes.AppendLine("| $(Split-Path -Leaf $apk) | ``$hash`` |")
}
[void]$notes.AppendLine("")
[void]$notes.AppendLine("Install help: see the README.")

# Reuse the release if the tag already exists, otherwise create it
try {
    $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Repo/releases/tags/$tag" -Headers $headers
    Write-Output "Release $tag already exists (id $($rel.id)) - uploading assets to it."
}
catch {
    $body = @{
        tag_name    = $tag
        name        = $tag
        body        = $notes.ToString()
        draft       = $false
        prerelease  = $false
    } | ConvertTo-Json
    $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Repo/releases" -Method Post -Headers $headers -Body $body -ContentType "application/json; charset=utf-8"
    Write-Output "Created release $tag (id $($rel.id))."
}

foreach ($apk in $ApkPaths) {
    $name = [Uri]::EscapeDataString([IO.Path]::GetFileName($apk))
    $uploadUrl = "https://uploads.github.com/repos/$Owner/$Repo/releases/$($rel.id)/assets?name=$name"
    Write-Output "Uploading $(Split-Path -Leaf $apk) ..."
    $resp = & curl.exe -sS -f -X POST `
        -H "Authorization: token $tok" `
        -H "Content-Type: application/vnd.android.package-archive" `
        --data-binary "@$apk" `
        $uploadUrl
    if ($LASTEXITCODE -ne 0) { throw "curl upload failed for $apk (exit $LASTEXITCODE)" }
}

Write-Output ""
Write-Output "Done: https://github.com/$Owner/$Repo/releases/tag/$tag"
