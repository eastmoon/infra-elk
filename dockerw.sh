#
# Copyright 2020 the original author jacky.eastmoon
#
# All commad module need 3 method :
# [command]        : Command script
# [command]-args   : Command script options setting function
# [command]-help   : Command description
# Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
# But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
#
# Ref : https://www.cyberciti.biz/faq/category/bash-shell/
# Ref : https://blog.longwin.com.tw/2017/04/bash-shell-script-get-self-file-name-2017/

# ------------------- shell setting -------------------

#!/bin/bash
set -e

# ------------------- declare CLI file variable -------------------

CLI_DIRECTORY=${PWD}
CLI_FILE=${BASH_SOURCE}
CLI_FILENAME=${BASH_SOURCE%.*}
CLI_FILEEXTENSION=${BASH_SOURCE##*.}

# ------------------- declare CLI variable -------------------

BREADCRUMB="cli"
COMMAND=""
COMMAND_BC_AGRS=()
COMMAND_AC_AGRS=()

# ------------------- declare variable -------------------

PROJECT_NAME=${PWD##*/}
PROJECT_ENV="dev"

# ------------------- declare function -------------------

# Command Parser
function main() {
    argv-parser ${@}
    for arg in ${COMMAND_BC_AGRS[@]}
    do
        IFS='=' read -ra ADDR <<< "${arg}"
        key=${ADDR[0]}
        value=${ADDR[1]}
        eval ${BREADCRUMB}-args ${key} ${value}
        main-args ${key} ${value}
    done
    # Execute command
    if [ ! -z ${COMMAND} ];
    then
        BREADCRUMB=${BREADCRUMB}-${COMMAND}
        main ${COMMAND_AC_AGRS[@]}
    else
        eval ${BREADCRUMB}
    fi
}

function main-args() {
    key=${1}
    value=${2}
    case ${key} in
        "--help")
            BREADCRUMB="${BREADCRUMB}-help"
            ;;
        "-h")
            BREADCRUMB="${BREADCRUMB}-help"
            ;;
    esac
}

function argv-parser() {
    COMMAND=""
    COMMAND_BC_AGRS=()
    COMMAND_AC_AGRS=()
    is_find_cmd=0
    for arg in ${@}
    do
        if [ ${is_find_cmd} -eq 0 ]
        then
            if [[ ${arg} =~ -+[a-zA-Z1-9]* ]]
            then
                COMMAND_BC_AGRS+=(${arg})
            else
              COMMAND=${arg}
              is_find_cmd=1
            fi
        else
            COMMAND_AC_AGRS+=(${arg})
        fi
    done
}


# ------------------- Main mathod -------------------

function cli() {
    cli-help
}

function cli-args() {
    key=${1}
    value=${2}
    case ${key} in
        "--prod")
            PROJECT_ENV="prod"
            ;;
    esac
}

function cli-help() {
    echo "This is a docker control script with project ${PROJECT_NAME}"
    echo "If not input any command, at default will show HELP"
    echo "Options:"
    echo "    --help, -h        Show more information with CLI."
    echo "    --prod            Setting project environment with "prod", default is "dev""
    echo ""
    echo "Command:"
    echo "    up                Startup Server."
    echo "    down              Close down Server."
    echo ""
    echo "Run 'cli [COMMAND] --help' for more information on a command."
}

# ------------------- Command "up" mathod -------------------

function cli-up {
    echo "> Server UP with ${PROJECT_ENV} environment"

    # Create .env for compose
    echo Current Environment %PROJECT_ENV%
    echo TAG=%PROJECT_NAME% > ./docker/.env

    echo "> Build docker images"
    docker build --rm ^
        -t docker-elasticsearch:${PROJECT_NAME} ^
        ./docker/elasticsearch

    docker build --rm ^
        -t docker-kibana:${PROJECT_NAME} ^
        ./docker/kibana

    echo "> Create cache"
    [ ! -d ./cache/s-data]
        mkdir ./cache/es-data
    )

    echo "> Startup docker container instance"
    docker-compose -f ./docker/docker-compose.yml up -d
}

function cli-up-args {
    return 0
}

function cli-up-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Startup Server"
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
}


# ------------------- Command "down" mathod -------------------

function cli-down {
    echo "> Server DOWN"
    docker-compose -f ./docker/docker-compose.yml down
}

function cli-down-args {
    return 0
}

function cli-down-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Close down Server"
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
}

# ------------------- execute script -------------------

main ${@}
