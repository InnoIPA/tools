@::!/dos/rocks
@echo off
goto :init

:header
    echo %__NAME% v%__VERSION%
    echo The script will use the w32tm.exe service and can specify one or more NTP servers.
    echo.
    goto :eof

:usage
    echo Usage:   %__BAT_NAME% [/?] [/v] [/e] [--config-server arg1 [arg2...]]
    echo Example: %__BAT_NAME% --config-server "time.stdtime.gov.tw" "clock.stdtime.gov.tw"
    echo.
    echo.  /?, --help           Shows this help
    echo.  /v, --version        Shows the version
    echo.  /e, --verbose        Shows detailed output
    echo.  --config-server      Configure NTP server
    goto :eof

:version
    if "%~1"=="full" call :header & goto :eof
    echo %__VERSION%
    goto :eof

:missing_argument
    call :header
    call :usage
    echo.
    echo ****                                   ****
    echo ****    MISSING "REQUIRED ARGUMENT"    ****
    echo ****                                   ****
    echo.
    goto :eof

:init
    set "__NAME=%~n0"
    set "__VERSION=1.0.0"
    set "__YEAR=2021"

    set "__BAT_FILE=%~0"
    set "__BAT_PATH=%~dp0"
    set "__BAT_NAME=%~nx0"

    set "OptVerbose="

    set "ConfigRemoteServer="
    set "RemoteServer="

:parse
    if "%~1"=="" goto :validate

    if /i "%~1"=="/?"       call :header & call :usage & goto :end
    if /i "%~1"=="-?"       call :header & call :usage & goto :end
    if /i "%~1"=="--help"   call :header & call :usage & goto :end

    if /i "%~1"=="/v"           call :version      & goto :end
    if /i "%~1"=="-v"           call :version      & goto :end
    if /i "%~1"=="--version"    call :version full & goto :end

    if /i "%~1"=="/e"           set "OptVerbose=yes" & shift & goto :parse
    if /i "%~1"=="-e"           set "OptVerbose=yes" & shift & goto :parse
    if /i "%~1"=="--verbose"    set "OptVerbose=yes" & shift & goto :parse
    
    if /i "%~1"=="--config-server"  set "ConfigRemoteServer=yes" & set "RemoteServer=%~2" & shift & shift & goto :parse
    
    if defined ConfigRemoteServer   set "RemoteServer=%RemoteServer% %~1" & shift & goto :parse

    shift
    goto :parse

:validate
    if not defined ConfigRemoteServer call :missing_argument & goto :end

:main
    if defined OptVerbose (
        echo **** DEBUG IS ON

        if defined ConfigRemoteServer       echo ConfigRemoteServer:    "%ConfigRemoteServer%"
        if not defined ConfigRemoteServer   echo ConfigRemoteServer:    not provided

        if defined RemoteServer             echo RemoteServer:          "%RemoteServer%"
        if not defined RemoteServer         echo RemoteServer:          not provided
    )

    call :restore_windows_time_service
    call :config_ntp_server

:end
    call :cleanup
    exit /B

:restore_windows_time_service
    net stop w32time
    w32tm /unregister
    w32tm /register
    net start w32time
    
    goto :eof

:config_ntp_server
    w32tm /config /manualpeerlist:"%RemoteServer%" /syncfromflags:manual /reliable:yes /update
    
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

    set "ConfigRemoteServer="
    set "RemoteServer="

    goto :eof