@::!/dos/rocks
@echo off

:: BatchGotAdmin
:-------------------------------------
REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

goto :init

:header
    echo %__NAME% v%__VERSION%
    echo The script will stop and unregister the w32tm.exe service.
    echo.
    goto :eof

:usage
    echo Usage:   %__BAT_NAME% [/?] [/v] [/e]
    echo Example: %__BAT_NAME%
    echo.
    echo.  /?, --help           Shows this help
    echo.  /v, --version        Shows the version
    echo.  /e, --verbose        Shows detailed output
    goto :eof

:version
    if "%~1"=="full" call :header & goto :eof
    echo %__VERSION%
    goto :eof

:init
    set "__NAME=%~n0"
    set "__VERSION=1.0.0"
    set "__YEAR=2021"

    set "__BAT_FILE=%~0"
    set "__BAT_PATH=%~dp0"
    set "__BAT_NAME=%~nx0"

    set "OptVerbose="

:parse
    if "%~1"=="" goto :main

    if /i "%~1"=="/?"       call :header & call :usage & goto :end
    if /i "%~1"=="-?"       call :header & call :usage & goto :end
    if /i "%~1"=="--help"   call :header & call :usage & goto :end

    if /i "%~1"=="/v"           call :version      & goto :end
    if /i "%~1"=="-v"           call :version      & goto :end
    if /i "%~1"=="--version"    call :version full & goto :end

    if /i "%~1"=="/e"           set "OptVerbose=yes" & shift & goto :parse
    if /i "%~1"=="-e"           set "OptVerbose=yes" & shift & goto :parse
    if /i "%~1"=="--verbose"    set "OptVerbose=yes" & shift & goto :parse

    shift
    goto :parse

:main
    if defined OptVerbose (
        echo **** DEBUG IS ON
    )

    call :stop_windows_time_service

:end
    call :cleanup
    pause
    exit /B

:stop_windows_time_service
    net stop w32time
    w32tm /unregister
    
    goto :eof

:cleanup
    REM The cleanup function is only really necessary if you
    REM are _not_ using SETLOCAL.
    set "__NAME="
    set "__VERSION="
    set "__YEAR="

    set "__BAT_FILE="
    set "__BAT_PATH="
    set "__BAT_NAME="

    set "OptVerbose="

    goto :eof