@echo off
setlocal

REM Function to remove '[5.5e]' from the compendium
:remove_5.5e
  powershell -Command "(gc %1) -replace '(\w) \[5.5e\]([,<])', '$1$2' | Out-File %1"
goto :eof

REM Function to display help text
:display_help
  echo Usage: %~n0 [-5.5e] [-android] [-h/-?] path-to-collections\collection-file.xml path-to-utilities\merge.xslt [optional path-to-compendium-destination-directory]
  echo.
  echo   -5.5e     Remove '[5.5e]' from the generated compendiums.
  echo   -android  Put item detail (rarity and attunement requirements) into description of items.
  echo   -h/-?     Display this help message.
  echo.
  echo Include path to XML collection file(s) as the first parameter to this batch script.
  echo Include the path to the merge.xslt file, typically at {repository}\Utilities\merge.xslt, as the second parameter to this batch script.
  echo.
  echo Examples:
  echo   %~n0 collections\collection1.xml Utilities\merge.xslt             Compile collections\collection1.xml.
  echo   %~n0 -5.5e -android collections\*.xml Utilities\merge.xslt Compendiums  Compile all XML files in collections\, remove '[5.5e]', enable Android mode, and output to Compendiums\.
  exit /b 0
goto :eof

REM Parse flags
set "flag_5.5e="
set "flag_android="

:parse_args
if "%1"=="-h" goto :display_help
if "%1"=="-?" goto :display_help
if "%1"=="-5.5e" (
  set "flag_5.5e=true"
  shift
  goto :parse_args
)
if "%1"=="-android" (
  set "flag_android=true"
  shift
  goto :parse_args
)
if "%1"=="--android" (
  set "flag_android=true"
  shift
  goto :parse_args
)

REM Check for required arguments
if "%1"=="" goto :display_help
if "%2"=="" goto :display_help

REM Chocolatey installations (if needed)
choco install xsltproc -y --force

set "xsltproc_args=--xinclude"
if defined flag_android (
  set "xsltproc_args=%xsltproc_args% --stringparam android true"
)

for %%A in ("%1") do (
  if "%3"=="" (
    xsltproc %xsltproc_args% -o "%%~nxA" "%~f2" "%%~fA"
    if defined flag_5.5e call :remove_5.5e "%%~nxA"
  ) else (
    if exist "%3\" (
      xsltproc %xsltproc_args% -o "%~f3\%%~nxA" "%~f2" "%%~fA"
      if defined flag_5.5e call :remove_5.5e "%~f3\%%~nxA"
    ) else (
      mkdir %3
      xsltproc %xsltproc_args% -o "%~f3\%%~nxA" "%~f2" "%%~fA"
      if defined flag_5.5e call :remove_5.5e "%~f3\%%~nxA"
    )
  )
)

endlocal