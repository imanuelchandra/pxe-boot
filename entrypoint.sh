#!/bin/bash

# set -uo pipefail

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

            mkdir -p /var/lib/nfs/rpc_pipefs

            mount -t nfsd nfsd /proc/fs/nfsd
            mount -t rpc_pipefs rpc_pipefs /var/lib/nfs/rpc_pipefs

            exports="/exports"

            if [ ! -r "$exports" ]; then
                echo "Please ensure '$exports' exists and is readable."
                exit 1
            else
                rm /etc/exports
                cp $exports /etc/exports
                echo "File /etc/exports....\n"
                cat /etc/exports
            fi

            
            pid=$(pidof rpc.mountd)

            echo "PID MOUNTD $pid \n"

           
            while [ -z "$pid" ]; do

                 echo "Starting rpcbind..."
                /sbin/rpcbind -w

                /usr/sbin/rpc.idmapd
                /usr/sbin/rpc.gssd -v
                /sbin/rpc.statd

                /usr/sbin/exportfs -uav
                /usr/sbin/rpc.nfsd 0

                /usr/sbin/rpc.nfsd -G 10 -N 2 -V 3

                if /usr/sbin/exportfs -rv; then
                    /usr/sbin/exportfs
                fi

               
                /usr/sbin/rpc.mountd -N 2 -V 3

                echo "Displaying rpcbind status..."
                /usr/bin/rpcinfo

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
        fi
    fi
else
    exec ${@}
fi