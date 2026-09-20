@echo off
setlocal EnableExtensions

REM Thin Windows wrapper around build-collections.ps1, which does the actual
REM compilation in parallel. Preserves the historical CLI:
REM   WIN-build-collections.bat [-5.5e] [-android] [-validate] [-h/-?] path-to-collections\collection-file.xml path-to-utilities\merge.xslt [optional output dir]

set "flag_5.5e="
set "flag_android="
set "flag_validate="
set "flag_maxjobs="

:parse
if "%~1"=="" goto help
if /I "%~1"=="-h" goto display_help
if /I "%~1"=="-?" goto display_help
if /I "%~1"=="/?" goto display_help
if /I "%~1"=="--help" goto display_help
if "%~1"=="-5.5e" ( set "flag_5.5e=-RemoveVersionTag" & shift & goto parse )
if /I "%~1"=="-android" ( set "flag_android=-Android" & shift & goto parse )
if /I "%~1"=="--android" ( set "flag_android=-Android" & shift & goto parse )
if /I "%~1"=="-validate" ( set "flag_validate=-Validate" & shift & goto parse )
if /I "%~1"=="--validate" ( set "flag_validate=-Validate" & shift & goto parse )
if /I "%~1"=="-maxjobs" ( set "flag_maxjobs=-MaxJobs %~2" & shift & shift & goto parse )
goto have_args

:have_args
if "%~1"=="" goto display_help
if "%~2"=="" goto display_help

set "COLLDIR=%~dp1"
if "%COLLDIR:~-1%"=="\" set "COLLDIR=%COLLDIR:~0,-1%"
set "COLLNAME=%~nx1"
set "MERGE=%~f2"
if "%~3"=="" ( set "OUTDIR=%~dp0Compendiums" ) else ( set "OUTDIR=%~f3" )
if "%OUTDIR:~-1%"=="\" set "OUTDIR=%OUTDIR:~0,-1%"

where xsltproc >nul 2>nul
if errorlevel 1 (
  echo xsltproc not found on PATH. Attempting to install via Chocolatey...
  choco install xsltproc -y --force
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-collections.ps1" -CollectionsDir "%COLLDIR%" -Merge "%MERGE%" -OutDir "%OUTDIR%" %flag_5.5e% %flag_android% %flag_validate% %flag_maxjobs% "%COLLNAME%"
exit /b %ERRORLEVEL%

:display_help
echo Usage: %~n0 [-5.5e] [-android] [-validate] [-h/-?] path-to-collections\collection-file.xml path-to-utilities\merge.xslt [optional output dir]
echo.
echo   -5.5e      Remove ' [5.5e]' from the generated compendiums.
echo   -android   Put item detail (rarity and attunement requirements) into item descriptions.
echo   -validate  Validate output XML against the schema (requires xmllint).
echo   -maxjobs N Cap parallel jobs (default: one per logical CPU, auto-capped by free memory).
echo   -h/-?      Display this help message.
echo.
echo Compilation is run in parallel (one xsltproc job per logical CPU) via build-collections.ps1,
echo automatically reducing parallelism when free physical memory is low.
echo.
echo Examples:
echo   %~n0 "collections\*.xml" Utilities\merge.xslt
echo       Compile all collections in collections\ into Compendiums\.
echo   %~n0 -5.5e -android "collections\*.xml" Utilities\merge.xslt Compendiums
echo       Compile all, remove ' [5.5e]', enable Android mode, output to Compendiums\.
echo.
echo In PowerShell, quote the wildcard so the shell does not expand it first; or run
echo build-collections.ps1 with no arguments to compile every collection.
exit /b 0
