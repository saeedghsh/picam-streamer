#!/bin/bash -ue

# ------------------------------------------------------------------------------
# --------------------------------------------------------------------- HELP DOC
# ------------------------------------------------------------------------------
SCRIPT_NAME="$(basename "$0")"
DOC="""
\nUsage example:
\n$ ./$SCRIPT_NAME -b -m rx -p 8001
\n$ ./$SCRIPT_NAME -b -m tx -p 8001 -hip 192.168.86.77 -l 120 
\n
\n* Commands
\n--buildorun(-b):\t\t\t build and run container
\n--killminate(-k):\t\t\t kill and rm container and rm image
\n
\n* select tx/rx mode
\n--mode(-m) <tx/rx>:\t\t\t run transmitter / receiver
\n
\n* parameters
\n--length(-l) <n>:\t\t\t transmit video for n seconds
\n--hostip(-hip) <transmitter_ip>
\n--port(-p) <n>
\n
"""

# ------------------------------------------------------------------------------
# -------------------------------------------------------- parse input arguments
# ------------------------------------------------------------------------------
function PARSE_ARGS {
    while [ -n "$1" ];
    do
        case "$1" in
            -b|--buildorun)
                COMMAND="buildorun" #$1
                shift # pass the command, i.e. $1
                ;;
            -k|--killminate)
                COMMAND="killminate" #$1
                shift # pass the command, i.e. $1
                ;;
            -m|--mode)
                MODE="$2"
                shift # pass the arg, i.e. $1
                shift # pass the val, i.e. $2
                ;;

            -hip|--hostip)
                HOSTIP="$2"
                shift # pass the arg, i.e. $1
                shift # pass the val, i.e. $2
                ;;
            -p|--port)
                PORT="$2"
                shift # pass the arg, i.e. $1
                shift # pass the val, i.e. $2
                ;;
            -l|--length)
                LENGTH="$2"
                shift # pass the arg, i.e. $1
                shift # pass the val, i.e. $2
                ;;

            *)
                echo "Option $1 not recognized"
                shift # pass the unknown, i.e. $1
                ;;
        esac
    done
}
PARSE_ARGS "$@"

# ------------------------------------------------------------------------------
# ------------------------------------------------------ set variables for TX/RX
# ------------------------------------------------------------------------------
case $MODE in
    tx)
        PYTHON_ARGS="-p ${PORT} -n ${HOSTIP} -l ${LENGTH}"
        DOCKER_FILE="Dockerfile.tx"
        ;;
    rx)
        PYTHON_ARGS="-p ${PORT}"
        DOCKER_FILE="Dockerfile.rx"
        ;;
    *)
        echo -e $DOC
        exit
        ;;
esac
DOCKER_IMAGE="picam_${MODE}"
DOCKER_CONTAINTER="picam_${MODE}_${PORT}"

# ------------------------------------------------------------------------------
# -------------------------------------------------------------------- execution
# ------------------------------------------------------------------------------
function BUILDORUN {
    docker image build --tag "${DOCKER_IMAGE}" --file "${DOCKER_FILE}" .
    docker container run --name "${DOCKER_CONTAINTER}" "${DOCKER_IMAGE}" "${PYTHON_ARGS}"
    # docker container run -it --name "${DOCKER_CONTAINTER}" "${DOCKER_IMAGE}" "${PYTHON_ARGS}"
}

function KILLMINATE {
    docker kill "${DOCKER_CONTAINTER}" || true
	docker container rm --force "${DOCKER_CONTAINTER}" || true
	docker image rm --force "${DOCKER_IMAGE}"
}

case "${COMMAND}" in
    buildorun)
        BUILDORUN
        ;;
    killminate)
        KILLMINATE
        ;;
    *)
        echo -e $DOC
        exit
        ;;
esac
