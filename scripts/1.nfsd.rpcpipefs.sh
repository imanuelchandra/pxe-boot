#!/bin/bash

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