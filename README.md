# TechConexion Mobile - Downloads

Public download page for the TechConexion mobile app (Android). The source code repository is private; this repo only hosts official releases.

## Download / Descargar

Get the latest version here:

**https://github.com/xbohiti/techConexion-mobile-releases/releases/latest**

| File | Device |
|---|---|
| `tcpr-32.apk` | 32-bit Android devices (armeabi-v7a) |
| `tcpr-64.apk` | 64-bit Android devices (arm64-v8a) - most modern phones |

Not sure which one? Nearly all phones made since 2017 are 64-bit; if the 64-bit APK fails to install, use the 32-bit one.

## Install / Instalar

**English**

1. Download the APK file for your device.
2. Open it from your notification bar or Downloads folder.
3. When prompted, allow "Install unknown apps" for your browser/file manager.
4. Tap Install and open the app.

**Espanol**

1. Descarga el archivo APK para tu dispositivo.
2. Abrelo desde la barra de notificaciones o la carpeta de descargas.
3. Cuando se te pida, permite "Instalar aplicaciones desconocidas" para tu navegador o administrador de archivos.
4. Toca Instalar y abre la aplicacion.

## Security / Seguridad

Every release includes SHA-256 checksums in its notes so you can verify your download:

```
certutil -hashfile tcpr-64.apk SHA256
```

Compare the output against the checksum listed in the release notes.

## Support

Issues and feedback: https://github.com/xbohiti/techConexion-mobile-releases/issues
