# Abre el emulador liviano con DNS y le instala el APK release.
# Uso: powershell -ExecutionPolicy Bypass -File tool\emulador.ps1

$sdk = "$env:LOCALAPPDATA\Android\Sdk"
$adb = "$sdk\platform-tools\adb.exe"
$apk = Join-Path $PSScriptRoot "..\build\app\outputs\flutter-apk\G62-2_Reservas_v1.0.0+1.apk"

# cerrar un emulador anterior para no tener dos abiertos
& $adb emu kill 2>$null | Out-Null
Start-Sleep -Seconds 3
Get-Process qemu-system-x86_64, emulator -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Process "$sdk\emulator\emulator.exe" -ArgumentList '-avd', 'Medium_Phone', '-memory', '1536', '-cores', '2', '-gpu', 'host', '-no-audio', '-no-boot-anim', '-no-snapshot', '-dns-server', '8.8.8.8,1.1.1.1'

Write-Host 'Esperando a que arranque...'
& $adb wait-for-device
do { Start-Sleep -Seconds 3 } until ((& $adb shell getprop sys.boot_completed 2>$null) -match '1')

if (Test-Path $apk) {
    & $adb install -r $apk
    & $adb shell am start -n co.edu.udem.reservas_g62/.MainActivity | Out-Null
    Write-Host 'Listo: app instalada y abierta.'
} else {
    Write-Host "No se encontro el APK en $apk. Compilar con: flutter build apk --release"
}
