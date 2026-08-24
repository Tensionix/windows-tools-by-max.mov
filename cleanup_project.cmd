@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

title Audion Windows Tools by Max.mov - Project Cleanup

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%A in ("%SCRIPT_DIR%") do set "ROOT=%%~fA"
set "ROOT_SLASH=%ROOT%\"

set "ASSUME_YES=0"
set "NO_PAUSE=0"
set "DRY_RUN=0"
set "KEEP_BACKUPS=0"

:PARSE_ARGS
if "%~1"=="" goto ARGS_DONE
if /I "%~1"=="/Y" set "ASSUME_YES=1"
if /I "%~1"=="/YES" set "ASSUME_YES=1"
if /I "%~1"=="--yes" set "ASSUME_YES=1"
if /I "%~1"=="/NOPAUSE" set "NO_PAUSE=1"
if /I "%~1"=="--no-pause" set "NO_PAUSE=1"
if /I "%~1"=="/DRYRUN" set "DRY_RUN=1"
if /I "%~1"=="--dry-run" set "DRY_RUN=1"
if /I "%~1"=="/KEEPBACKUPS" set "KEEP_BACKUPS=1"
if /I "%~1"=="--keep-backups" set "KEEP_BACKUPS=1"
shift
goto PARSE_ARGS

:ARGS_DONE
if not exist "%ROOT%\App.ps1" (
  echo [ERROR] This script must be launched from Audion Windows Tools by Max.mov root.
  echo Root: %ROOT%
  call :PAUSE_IF_NEEDED
  exit /b 1
)
if not exist "%ROOT%\Engine\TweakEngine.psm1" (
  echo [ERROR] Project marker not found: Engine\TweakEngine.psm1
  call :PAUSE_IF_NEEDED
  exit /b 1
)

echo ======================================================================
echo   AUDION WINDOWS TOOLS BY MAX.MOV - PROJECT CLEANUP
echo ======================================================================
echo Root:
echo   %ROOT%
echo.
echo This cleanup removes local/generated state:
echo   - logs and runtime scratch folders
echo   - local GUI path history
echo   - undo records under Data\backups - see the warning below
echo   - install download cache
echo   - staged release manifests
echo   - portable PowerShell under Engine\PowerShell
echo   - Python bytecode and common tool caches
echo.
echo WARNING about Data\backups. It is not a cache and nothing can rebuild it.
echo Each file there records what a setting held BEFORE a tweak was applied, and
echo that original value is already overwritten on the machine. Deleting these
echo files does not change any setting - it removes the ability to undo them.
echo Pass /KEEPBACKUPS to leave the folder alone.
echo.
echo Preserved:
echo   - App.ps1 and Engine source scripts
echo   - Engine\MainWindow.xaml, Engine\Themes.psd1
echo   - Manifests, Strings, Assets
echo   - config\version.json, docs, licenses and Install scripts
echo.

if "%DRY_RUN%"=="1" (
  echo Mode: DRY RUN
) else if not "%ASSUME_YES%"=="1" (
  choice /C YNQ /N /M "Continue cleanup? [Y/N/Q] "
  if errorlevel 3 exit /b 2
  if errorlevel 2 exit /b 0
)

echo.
echo [CLEAN] Starting...

call :CLEAR_DIR "logs"
call :CLEAR_DIR "._runtime"
call :CLEAR_DIR "Install\download"

if "%KEEP_BACKUPS%"=="1" (
  echo [KEEP]  %ROOT%\Data\backups
) else (
  call :CLEAR_DIR "Data\backups"
)

call :REMOVE_DIR "Engine\PowerShell"
call :REMOVE_DIR "Engine\_pwsh_tmp"
call :REMOVE_DIR "Engine\_powershell_tmp"

call :REMOVE_FILE "release_manifest.json"
call :REMOVE_FILE "config\path_history.json"
call :REMOVE_FILE "config\workspace_paths.json"
call :REMOVE_FILE "config\gui_settings.json"

echo [CACHE] Removing Python bytecode and common tool caches...
if "%DRY_RUN%"=="1" (
  for /d /r "%ROOT%" %%D in (__pycache__ .pytest_cache .mypy_cache .ruff_cache htmlcov) do if exist "%%D" echo   rmdir "%%D"
  for /r "%ROOT%" %%F in (*.pyc *.pyo .coverage) do if exist "%%F" echo   del "%%F"
) else (
  for /d /r "%ROOT%" %%D in (__pycache__ .pytest_cache .mypy_cache .ruff_cache htmlcov) do if exist "%%D" rd /s /q "%%D" >nul 2>nul
  for /r "%ROOT%" %%F in (*.pyc *.pyo .coverage) do if exist "%%F" del /f /q "%%F" >nul 2>nul
)

echo.
if "%DRY_RUN%"=="1" (
  echo [OK] Dry run finished.
) else (
  echo [OK] Cleanup finished.
)
call :PAUSE_IF_NEEDED
exit /b 0

:CLEAR_DIR
set "REL=%~1"
set "TARGET=%ROOT%\%REL%"
call :ASSERT_INSIDE "%TARGET%"
if errorlevel 1 exit /b 1
echo [CLEAR] %TARGET%
if "%DRY_RUN%"=="1" (
  echo   clear contents
  exit /b 0
)
if exist "%TARGET%\" (
  for /f "delims=" %%I in ('dir /a /b "%TARGET%" 2^>nul') do (
    if exist "%TARGET%\%%I\" (
      rd /s /q "%TARGET%\%%I" >nul 2>nul
    ) else (
      del /f /q "%TARGET%\%%I" >nul 2>nul
    )
  )
) else (
  mkdir "%TARGET%" >nul 2>nul
)
exit /b 0

:REMOVE_DIR
set "REL=%~1"
set "TARGET=%ROOT%\%REL%"
call :ASSERT_INSIDE "%TARGET%"
if errorlevel 1 exit /b 1
if exist "%TARGET%\" (
  echo [RMDIR] %TARGET%
  if "%DRY_RUN%"=="1" (
    echo   rmdir "%TARGET%"
  ) else (
    rd /s /q "%TARGET%" >nul 2>nul
  )
)
exit /b 0

:REMOVE_FILE
set "REL=%~1"
set "TARGET=%ROOT%\%REL%"
call :ASSERT_INSIDE "%TARGET%"
if errorlevel 1 exit /b 1
if exist "%TARGET%" (
  echo [DEL]   %TARGET%
  if "%DRY_RUN%"=="1" (
    echo   del "%TARGET%"
  ) else (
    del /f /q "%TARGET%" >nul 2>nul
  )
)
exit /b 0

:ASSERT_INSIDE
set "CHECK_PATH=%~f1"
if not defined CHECK_PATH exit /b 1
if /I "%CHECK_PATH%"=="%ROOT%" exit /b 1
set "CHECK_REST=!CHECK_PATH:%ROOT_SLASH%=!"
if /I "!CHECK_REST!"=="!CHECK_PATH!" (
  echo [ERROR] Refusing to clean outside project root: %CHECK_PATH%
  exit /b 1
)
exit /b 0

:PAUSE_IF_NEEDED
if not "%NO_PAUSE%"=="1" pause
goto :eof
