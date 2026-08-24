@echo off
:: Audion Windows Tools by Max.mov - fallback launcher
::
:: NOT the canonical entry point. Start.exe in the project root is. This exists for the one case
:: Start.exe cannot cover: Windows refusing to run an unsigned local executable. It resolves
:: PowerShell the same way Start.exe does - bundled portable 7, then system 7, then the Windows
:: PowerShell 5.1 that ships with Windows.
::
:: It lives in Engine\ rather than the root, so the root shows a single way in.

:: %~f expands to a full, normalised path - without it APP_ROOT would keep the ".." segment, which
:: would then travel through -File into $PSScriptRoot and become the app's AppRoot.
for %%I in ("%~dp0..") do set "APP_ROOT=%%~fI"
cd /d "%APP_ROOT%"

set "PORTABLE_PWSH=%APP_ROOT%\Engine\PowerShell\pwsh.exe"
set "PWSH_EXE="

if exist "%PORTABLE_PWSH%" (
    set "PWSH_EXE=%PORTABLE_PWSH%"
) else (
    where pwsh.exe >nul 2>nul
    if not errorlevel 1 set "PWSH_EXE=pwsh.exe"
)

if not defined PWSH_EXE (
    where powershell.exe >nul 2>nul
    if not errorlevel 1 set "PWSH_EXE=powershell.exe"
)

if not defined PWSH_EXE (
    echo [ERROR] PowerShell not found.
    echo [INFO] Install portable PowerShell 7: Install\Install-Portable-PowerShell.cmd
    pause
    exit /b 1
)

if not exist "%APP_ROOT%\App.ps1" (
    echo [ERROR] App.ps1 was not found next to the project root: %APP_ROOT%
    pause
    exit /b 1
)

"%PWSH_EXE%" -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File "%APP_ROOT%\App.ps1"
