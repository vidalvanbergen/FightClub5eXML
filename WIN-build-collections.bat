@echo off
setlocal

REM Function to remove '[2024]' from the compendium
:remove_2024
  powershell -Command "(gc %1) -replace '(\w) \[2024\]([,<])', '$1$2' | Out-File %1"
goto :eof

REM Function to display help text
:display_help
  echo Usage: %~n0 [-2024] [-h/-?] path-to-collections\collection-file.xml path-to-utilities\merge.xslt [optional path-to-compendium-destination-directory]
  echo.
  echo   -2024     Remove '[2024]' from the generated compendiums.
  echo   -h/-?     Display this help message.
  echo.
  echo Include path to XML collection file(s) as the first parameter to this batch script.
  echo Include the path to the merge.xslt file, typically at {repository}\Utilities\merge.xslt, as the second parameter to this batch script.
  echo.
  echo Examples:
  echo   %~n0 collections\collection1.xml Utilities\merge.xslt             Compile collections\collection1.xml.
  echo   %~n0 -2024 collections\*.xml Utilities\merge.xslt Compendiums  Compile all XML files in collections\, remove '[2024]', and output to Compendiums\.
  exit /b 0
goto :eof

REM Check for help flags
if "%1"=="-h" goto :display_help
if "%1"=="-?" goto :display_help

REM Check for -2024 flag
set "flag_2024="
if "%1"=="-2024" (
  set "flag_2024=true"
  shift
)

REM Check for required arguments
if "%1"=="" goto :display_help
if "%2"=="" goto :display_help

REM Chocolatey installations (if needed)
choco install xsltproc -y --force

for %%A in ("%1") do (
  if "%3"=="" (
    xsltproc -o "%%~nxA" "%~f2" "%%~fA"
    if defined flag_2024 call :remove_2024 "%%~nxA"
  ) else (
    if exist "%3\" (
      xsltproc -o "%~f3\%%~nxA" "%~f2" "%%~fA"
      if defined flag_2024 call :remove_2024 "%~f3\%%~nxA"
    ) else (
      mkdir %3
      xsltproc -o "%~f3\%%~nxA" "%~f2" "%%~fA"
      if defined flag_2024 call :remove_2024 "%~f3\%%~nxA"
    )
  )
)

endlocal