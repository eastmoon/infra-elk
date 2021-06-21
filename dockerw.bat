@rem
@rem Copyright 2020 the original author jacky.eastmoon
@rem All commad module need 3 method :
@rem [command]        : Command script
@rem [command]-args   : Command script options setting function
@rem [command]-help   : Command description
@rem Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
@rem But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
@rem NOTE, batch call [command]-args it could call correct one or call [command] and "-args" is parameter.
@rem

:: ------------------- batch setting -------------------
@rem setting batch file
@rem ref : https://www.tutorialspoint.com/batch_script/batch_script_if_else_statement.htm
@rem ref : https://poychang.github.io/note-batch/

@echo off
setlocal
setlocal enabledelayedexpansion

:: ------------------- declare CLI file variable -------------------
@rem retrieve project name
@rem Ref : https://www.robvanderwoude.com/ntfor.php
@rem Directory = %~dp0
@rem Object Name With Quotations=%0
@rem Object Name Without Quotes=%~0
@rem Bat File Drive = %~d0
@rem Full File Name = %~n0%~x0
@rem File Name Without Extension = %~n0
@rem File Extension = %~x0

set CLI_DIRECTORY=%~dp0
set CLI_FILE=%~n0%~x0
set CLI_FILENAME=%~n0
set CLI_FILEEXTENSION=%~x0

:: ------------------- declare CLI variable -------------------

set BREADCRUMB=cli
set COMMAND=
set COMMAND_BC_AGRS=
set COMMAND_AC_AGRS=

:: ------------------- declare variable -------------------

for %%a in ("%cd%") do (
    set PROJECT_NAME=%%~na
)
set PROJECT_ENV=dev
set PROJECT_SSH_USER=somesshuser
set PROJECT_SSH_PASS=somesshpass

:: ------------------- execute script -------------------

call :main %*
goto end

:: ------------------- declare function -------------------

:main (
    call :argv-parser %*
    call :%BREADCRUMB%-args %COMMAND_BC_AGRS%
    call :main-args %COMMAND_BC_AGRS%
    IF defined COMMAND (
        set BREADCRUMB=%BREADCRUMB%-%COMMAND%
        call :main %COMMAND_AC_AGRS%
    ) else (
        call :%BREADCRUMB%
    )
    goto end
)
:main-args (
    for %%p in (%*) do (
        if "%%p"=="-h" ( set BREADCRUMB=%BREADCRUMB%-help )
        if "%%p"=="--help" ( set BREADCRUMB=%BREADCRUMB%-help )
    )
    goto end
)
:argv-parser (
    set COMMAND=
    set COMMAND_BC_AGRS=
    set COMMAND_AC_AGRS=
    set is_find_cmd=
    for %%p in (%*) do (
        IF NOT defined is_find_cmd (
            echo %%p | findstr /r "\-" >nul 2>&1
            if errorlevel 1 (
                set COMMAND=%%p
                set is_find_cmd=TRUE
            ) else (
                set COMMAND_BC_AGRS=!COMMAND_BC_AGRS! %%p
            )
        ) else (
            set COMMAND_AC_AGRS=!COMMAND_AC_AGRS! %%p
        )
    )
    goto end
)

:: ------------------- Main mathod -------------------

:cli (
    goto cli-help
)

:cli-args (
    goto end
)

:cli-help (
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo If not input any command, at default will show HELP
    echo.
    echo Options:
    echo      --help, -h        Show more information with CLI.
    echo.
    echo Command:
    echo      up                Start service with docker compose.
    echo      down              Stop service with docker compose.
    echo.
    echo Run 'cli [COMMAND] --help' for more information on a command.
    goto end
)

:: ------------------- Command "start" mathod -------------------

:cli-up-docker-prepare (
    @rem Create .env for compose
    echo Current Environment %PROJECT_ENV%
    echo TAG=%PROJECT_NAME% > ./docker/.env

    echo ^> Build ebook Docker images
    docker build --rm ^
        -t docker-elasticsearch:%PROJECT_NAME% ^
        .\docker\elasticsearch

    docker build --rm ^
        -t docker-logstash:%PROJECT_NAME% ^
        .\docker\logstash

    docker build --rm ^
        -t docker-kibana:%PROJECT_NAME% ^
        .\docker\kibana

    IF NOT EXIST cache\es-data (
        mkdir cache\es-data
    )
    goto end
)

:cli-up (
    echo ^> Build ebook Docker images
    call :cli-up-docker-prepare

    echo ^> Startup docker container instance
    @rem Run next deveopment with stdout
    docker-compose -f ./docker/docker-compose.yml up -d

    goto end
)

:cli-up-args (
    for %%p in (%*) do (
        if "%%p"=="--dev" ( set DEVELOPER=1 )
    )
    goto end
)

:cli-up-help (
    echo Start service with docker compose.
    echo.
    echo Options:
    echo.
    goto end
)

:: ------------------- Command "down" mathod -------------------

:cli-down (
    @rem Close docker container instance by docker-compose
    docker-compose -f ./docker/docker-compose.yml down

    goto end
)

:cli-down-args (
    goto end
)

:cli-down-help (
    echo Close docker container instance by docker-compose.
    goto end
)

:: ------------------- End method-------------------

:end (
    endlocal
)
