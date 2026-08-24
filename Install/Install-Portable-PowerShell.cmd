@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

title Audion - Install Portable PowerShell

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%A in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fA"

set "DL=%ROOT%\install\download"
set "PWSH_DIR=%ROOT%\Engine\PowerShell"
set "TMP=%ROOT%\Engine\_pwsh_tmp"
set "ZIP=%DL%\pwsh_windows_x64.zip"
set "PS_EXE="
set "NO_PAUSE=0"

if /I "%~1"=="/NOPAUSE" set "NO_PAUSE=1"
if /I "%~1"=="--no-pause" set "NO_PAUSE=1"

rem Bootstrap with a non-target PowerShell when possible, so the target
rem Engine\PowerShell directory can be safely replaced.
where pwsh.exe >nul 2>nul && set "PS_EXE=pwsh.exe"
if not defined PS_EXE where powershell.exe >nul 2>nul && set "PS_EXE=powershell.exe"
if not defined PS_EXE if exist "%PWSH_DIR%\pwsh.exe" set "PS_EXE=%PWSH_DIR%\pwsh.exe"

if not exist "%DL%\" mkdir "%DL%" >nul 2>nul
if not exist "%PWSH_DIR%\" mkdir "%PWSH_DIR%" >nul 2>nul

echo ======================================================================
echo   AUDION - INSTALL PORTABLE POWERSHELL
echo ======================================================================
echo Root:    %ROOT%
echo Target:  %PWSH_DIR%
echo DL:      %DL%
echo PS:      %PS_EXE%
echo.

if not defined PS_EXE goto ERR_NOPS

echo [1/4] Resolving latest PowerShell release from GitHub...
"%PS_EXE%" -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$zip='%ZIP%';" ^
  "$headers=@{'User-Agent'='Audion-WinGet'}; if($env:GITHUB_TOKEN){$headers['Authorization']='Bearer '+$env:GITHUB_TOKEN};" ^
  "$repo='https://github.com/PowerShell/PowerShell'; $api='https://api.github.com/repos/PowerShell/PowerShell/releases/latest'; $url=$null; $tag=$null; $downloaded=$false;" ^
  "try { $resp=$null; try { $resp=Invoke-WebRequest -Uri ($repo + '/releases/latest') -Headers $headers -MaximumRedirection 0 -ErrorAction Stop } catch { $resp=$_.Exception.Response }; $loc=$null; if($resp){ if($resp.Headers.Location){ $loc=[string]$resp.Headers.Location } elseif($resp.Headers['Location']){ $loc=[string]$resp.Headers['Location'] } }; if(-not $loc -or $loc -notmatch '/tag/(?<tag>v?[0-9][^/]+)$'){ throw 'Could not resolve latest PowerShell release tag without API.' }; $tag=$Matches.tag; $version=$tag.TrimStart('v'); $url=($repo + '/releases/download/' + $tag + '/PowerShell-' + $version + '-win-x64.zip'); Write-Host ('[INFO] Resolved through releases/latest redirect: ' + $tag) } catch { Write-Host ('[WARN] releases/latest resolver unavailable, using GitHub API: ' + $_.Exception.Message) };" ^
  "if($url){ try { Write-Host ('[URL] ' + $url); Invoke-WebRequest -Uri $url -Headers $headers -OutFile $zip; $downloaded=$true; Write-Host '[INFO] Direct release download succeeded.' } catch { Write-Host ('[WARN] Direct asset URL failed, using GitHub API: ' + $_.Exception.Message); $url=$null; Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue } };" ^
  "if(-not $url){ $r=Invoke-RestMethod -Headers $headers $api; $tag=$r.tag_name; $a=$null; foreach($item in $r.assets){ if($item.name -like '*-win-x64.zip'){ $a=$item; break } }; if(-not $a){ throw 'Asset not found: *-win-x64.zip' }; $url=($a.browser_download_url).Trim(); Write-Host '[INFO] Resolved through GitHub API fallback.' };" ^
  "Write-Host ('[URL] ' + $url);" ^
  "Write-Host ('[VER] ' + $tag);" ^
  "if(-not $downloaded){ Invoke-WebRequest -Uri $url -Headers $headers -OutFile $zip }"
if errorlevel 1 goto ERR_DOWNLOAD

if not exist "%ZIP%" goto ERR_DOWNLOAD
for %%F in ("%ZIP%") do echo [OK] Downloaded: %%~zF bytes
echo.

echo [2/4] Extracting archive...
if exist "%TMP%" rd /s /q "%TMP%" >nul 2>nul
mkdir "%TMP%" >nul 2>nul

"%PS_EXE%" -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "Expand-Archive -Path '%ZIP%' -DestinationPath '%TMP%' -Force"
if errorlevel 1 goto ERR_EXTRACT

if not exist "%TMP%\pwsh.exe" goto ERR_NOEXE
echo [OK] Extracted successfully
echo.

echo [3/4] Replacing Engine\PowerShell\ ...
call :RESET_DIR "%PWSH_DIR%"
if errorlevel 1 goto ERR_COPY

"%PS_EXE%" -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "Copy-Item '%TMP%\*' '%PWSH_DIR%\' -Recurse -Force"
if errorlevel 1 goto ERR_COPY

echo [OK] Copied to Engine\PowerShell\
echo.

echo [4/4] Cleanup...
rd /s /q "%TMP%" >nul 2>nul
rd /s /q "%DL%" >nul 2>nul
echo [OK] Temp removed

echo.
echo [SUCCESS] Portable PowerShell installed: %PWSH_DIR%\pwsh.exe
"%PWSH_DIR%\pwsh.exe" --version
echo.
call :PAUSE_IF_NEEDED
exit /b 0

:ERR_NOPS
echo [ERROR] No PowerShell found (portable, system pwsh, or powershell.exe).
echo [INFO]  On Windows 10+ powershell.exe should usually be available.
call :PAUSE_IF_NEEDED
exit /b 1

:ERR_DOWNLOAD
echo [ERROR] Download failed. Check internet connection or GitHub rate limit.
call :PAUSE_IF_NEEDED
exit /b 1

:ERR_EXTRACT
echo [ERROR] Extraction failed.
call :PAUSE_IF_NEEDED
exit /b 1

:ERR_NOEXE
echo [ERROR] pwsh.exe not found after extraction.
call :PAUSE_IF_NEEDED
exit /b 1

:ERR_COPY
echo [ERROR] Copy to Engine\PowerShell\ failed.
call :PAUSE_IF_NEEDED
exit /b 1

:RESET_DIR
set "TARGET_DIR=%~1"
if not defined TARGET_DIR exit /b 1
if /I not "%TARGET_DIR%"=="%PWSH_DIR%" exit /b 1
if exist "%TARGET_DIR%\" rd /s /q "%TARGET_DIR%" >nul 2>nul
mkdir "%TARGET_DIR%" >nul 2>nul
if not exist "%TARGET_DIR%\" exit /b 1
exit /b 0

:PAUSE_IF_NEEDED
if not "%NO_PAUSE%"=="1" pause
goto :eof
