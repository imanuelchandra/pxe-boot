#!/bin/bash

sudo mount -t nfsd nfsd /proc/fs/nfsd

sudo mkdir -p /var/lib/nfs/rpc_pipefs
sudo chown -R pxeadmin:pxeadmin /var/lib/nfs
sudo mount -t rpc_pipefs rpc_pipefs /var/lib/nfs/rpc_pipefs

echo "===================================\n"
echo "Verify NFSD Are Mounting\n"
echo "===================================\n"
ls /proc/fs/nfsd
echo "\n"
echo "===================================\n"
echo "Verify RPCPIPEFS Are Mounting\n"
echo "===================================\n"
ls /var/lib/nfs/rpc_pipefs
echo "\n"