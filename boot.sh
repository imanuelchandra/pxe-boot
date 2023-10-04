#!/bin/bash

set -uo pipefail

trap "stop; exit 0;" SIGTERM SIGINT

stop(){
    sudo /usr/sbin/exportfs -uav
    sudo /usr/sbin/rpc.nfsd 0
    nfsd=$(pidof rpc.nfsd)
    mountd=$(pidof rpc.mountd)
    rpcbind=$(pidof rpcbind)
    sudo kill -TERM $nfsd $mountd $rpcbind > /dev/null 2>&1
    echo "Terminated."
    exit
}

init(){
    # declare directory required by this image in array
    declare -a dir_req=("/config" "/data" "/scripts" "/log")
 
    # loop through the array of directory list required by this image
    for i in "${dir_req[@]}"
    do
        # check for required directory, if it is does not exits, throw exit code 1
        if [ ! -d "$i" ]; then
            echo "Please ensure config, data, scripts, and log directory exists."
            exit 1
        fi

        # check for required directory, scripts
        # list the content of scripts directory, and pipe into IO
        # and execute the script
        if [ $i = "/scripts" ]; then
            cd $i
            for scripts in $(find . -type f -atime -1 -name '*.*' | sed 's_.*/__' | sort -n);
            do
                if [ -n "$scripts" ]; then

                    if [ -x  "$scripts" ]; then
                        sudo chmod +x $scripts
                        ./$scripts
                    fi
                fi
            done;
        fi
    done

}

start(){
init

pid=$(pidof rpc.mountd)

echo "PID MOUNTD $pid \n"


while [ -z "$pid" ]; do

    echo "Starting rpcbind..."
    sudo /sbin/rpcbind -w

    sudo /usr/sbin/rpc.idmapd
    sudo /usr/sbin/rpc.gssd -v
    sudo /sbin/rpc.statd

    sudo /usr/sbin/exportfs -uav
    sudo /usr/sbin/rpc.nfsd 0

    sudo /usr/sbin/rpc.nfsd -G 10 -N 2 -N 3

    if sudo /usr/sbin/exportfs -rav; then
        sudo /usr/sbin/exportfs
    fi

    
    sudo /usr/sbin/rpc.mountd -N 2 -N 3

    echo "Displaying rpcbind status..."
    sudo /usr/bin/rpcinfo

    pid_mountd=$(pidof rpc.mountd)

    
    if [ -n "$pid_mountd" ]; then
        echo "PID MOUNTD AFTER $pid_mountd \n"
        break
    else
        sleep 2
    fi
done

echo Started

while true; do
    
    pid_mountd=$(pidof rpc.mountd)
    
    if [ -z "$pid_mountd" ]; then
        echo "NFS has failed, exiting, so Docker can restart the container..."
        break
    fi

    sleep 1

done

}

if [ $# -eq 1 -a -n "$1" ]; then
    if ! which "$1" >/dev/null; then
       
        NEXT_WAIT_TIME=1

        until [ -e "/sys/class/net/$1" ] || [ $NEXT_WAIT_TIME -eq 4 ]; do
            sleep $(( NEXT_WAIT_TIME++ ))
            echo "Waiting for interface '$1' to become available... ${NEXT_WAIT_TIME}"
        done

        if [ -e "/sys/class/net/$1" ]; then

            container_id=$(grep docker /proc/self/cgroup | sort -n | head -n 1 | cut -d: -f3 | cut -d/ -f3)
            if perl -e '($id,$name)=@ARGV;$short=substr $id,0,length $name;exit 1 if $name ne $short;exit 0' $container_id $HOSTNAME; then
                echo "You must add the 'docker run' option '--net=host' if you want to provide DHCP service to the host network."
            fi
            
            start
        fi
    fi
else
    exec ${@}
fi