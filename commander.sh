#!/bin/bash -ue

LENGTH=120
RPI_USER="pi"
RPI_COUNT=3
RPI_PORT=(8001 8002 8003)
RPI_IP=("192.168.86.77" "192.168.86.28" "192.168.86.78")
RPI_HOSTNAME=("raspberry-pi-01" "raspberry-pi-02" "raspberry-pi-03")

echo -e "\n***** KILLMINATING ALL\n"
for ((i=0;i<$RPI_COUNT;i++)) do
    bash launcher.sh --killminate --mode rx --port "${RPI_PORT[$i]}"
    echo -e ""
done

echo -e "\n***** BUILDORUNNING ALL\n"
for ((i=0;i<$RPI_COUNT;i++)) do
    bash launcher.sh --buildorun --mode rx --port "${RPI_PORT[$i]}"
done


# for ((i=0;i<$RPI_COUNT;i++)) do
#     scp -r src Dockerfile.tx launcher.sh "${RPI_USER}@${RPI_IP[$i]}":~/

#     PYTHON_ARGS="--port ${RPI_PORT[$i]}"
#     LAUNCH_ARGS="--killminate --mode tx ${PYTHON_ARGS}"
#     ssh "$RPI_USER@${RPI_IP[$i]}" bash launcher.sh "${LAUNCH_ARGS}"
    
#     PYTHON_ARGS="--port ${RPI_PORT[$i]} --hostip ${RPI_IP[$i]} --length ${LENGTH}"
#     LAUNCH_ARGS="--buildorun --mode tx ${PYTHON_ARGS}"
#     ssh "$RPI_USER@${RPI_IP[$i]}" bash launcher.sh "${LAUNCH_ARGS}"
# done
