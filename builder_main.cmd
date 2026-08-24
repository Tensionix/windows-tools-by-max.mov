@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

title Audion Windows Tools by Max.mov - Builder

set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%" || exit /b 1

set "DIRECT=0"
if not "%~1"=="" (
  set "RAW=%~1"
  set "DIRECT=1"
  goto DISPATCH
)

:MAIN
cls
echo ======================================================================
echo   AUDION WINDOWS TOOLS BY MAX.MOV - BUILDER
echo ======================================================================
echo Root: %BASE_DIR%
echo.
echo [04] POWERSHELL                            ^| install_pwsh      ^| install portable PowerShell 7 into Engine\PowerShell
echo.
echo [70] CLEAN INSTALL CACHE                   ^| clean_cache       ^| clean installer downloads, staging folders and bytecode
echo [71] VERIFY / DOCTOR                       ^| verify            ^| check portable PowerShell payload
echo.
echo [95] OPEN install                          ^| open_install      ^| explorer Install
echo [96] OPEN PowerShell                       ^| open_pwsh         ^| explorer Engine\PowerShell
echo.
echo [00] EXIT                                  ^| exit              ^| close builder
echo.
set "RAW="
set /p RAW="Select step number or id: "

:DISPATCH
call :TRIM RAW
if not defined RAW goto MAIN
if /I "%RAW%"=="04" goto INSTALL_PWSH
if /I "%RAW%"=="4" goto INSTALL_PWSH
if /I "%RAW%"=="04:install_pwsh" goto INSTALL_PWSH
if /I "%RAW%"=="install_pwsh" goto INSTALL_PWSH
if /I "%RAW%"=="70" goto CLEAN_CACHE
if /I "%RAW%"=="70:clean_cache" goto CLEAN_CACHE
if /I "%RAW%"=="clean_cache" goto CLEAN_CACHE
if /I "%RAW%"=="71" goto VERIFY
if /I "%RAW%"=="71:verify" goto VERIFY
if /I "%RAW%"=="verify" goto VERIFY
if /I "%RAW%"=="95" goto OPEN_INSTALL
if /I "%RAW%"=="95:open_install" goto OPEN_INSTALL
if /I "%RAW%"=="open_install" goto OPEN_INSTALL
if /I "%RAW%"=="96" goto OPEN_PWSH
if /I "%RAW%"=="96:open_pwsh" goto OPEN_PWSH
if /I "%RAW%"=="open_pwsh" goto OPEN_PWSH
if /I "%RAW%"=="00" exit /b 0
if /I "%RAW%"=="0" exit /b 0
if /I "%RAW%"=="exit" exit /b 0
goto MAIN

:INSTALL_PWSH
call "%BASE_DIR%\Install\Install-Portable-PowerShell.cmd" /NOPAUSE
set "STEP_ERROR=%ERRORLEVEL%"
if "%DIRECT%"=="1" exit /b %STEP_ERROR%
goto MAIN

:CLEAN_CACHE
if exist "%BASE_DIR%\Install\download" rd /s /q "%BASE_DIR%\Install\download" >nul 2>nul
if exist "%BASE_DIR%\Engine\_pwsh_tmp" rd /s /q "%BASE_DIR%\Engine\_pwsh_tmp" >nul 2>nul
if exist "%BASE_DIR%\Engine\_powershell_tmp" rd /s /q "%BASE_DIR%\Engine\_powershell_tmp" >nul 2>nul
if not exist "%BASE_DIR%\Install\download" mkdir "%BASE_DIR%\Install\download" >nul 2>nul
for /d /r "%BASE_DIR%" %%D in (__pycache__ .pytest_cache .mypy_cache .ruff_cache htmlcov) do if exist "%%D" rd /s /q "%%D" >nul 2>nul
for /r "%BASE_DIR%" %%F in (*.pyc *.pyo .coverage) do if exist "%%F" del /f /q "%%F" >nul 2>nul
echo [OK] Install cache cleaned.
if "%DIRECT%"=="1" exit /b 0
goto MAIN

:VERIFY
if exist "%BASE_DIR%\Engine\PowerShell\pwsh.exe" (
  "%BASE_DIR%\Engine\PowerShell\pwsh.exe" --version
) else (
  echo [MISS] Engine\PowerShell\pwsh.exe
)
if "%DIRECT%"=="1" exit /b 0
goto MAIN

:OPEN_INSTALL
start "" explorer "%BASE_DIR%\Install"
if "%DIRECT%"=="1" exit /b 0
goto MAIN

:OPEN_PWSH
start "" explorer "%BASE_DIR%\Engine\PowerShell"
if "%DIRECT%"=="1" exit /b 0
goto MAIN

:TRIM
for /f "tokens=* delims= " %%z in ("!%~1!") do set "%~1=%%z"
:TRIM_R
if "!%~1:~-1!"==" " set "%~1=!%~1:~0,-1!" & goto TRIM_R
goto :eof
