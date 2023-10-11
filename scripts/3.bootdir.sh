#!/bin/bash

# sudo chown pxeadmin:pxeadmin /data
# sudo chmod -R 777 /data
mkdir /home/pxeadmin/pxe_root
sudo bindfs --force-user=pxeadmin --force-group=pxeadmin \
    --create-for-user=6565 --create-for-group=6565 \
    --chown-ignore --chgrp-ignore \
    /data/pxe_root /home/pxeadmin/pxe_root

echo "===================================\n"
echo "PXE Root Directory \n"
echo "===================================\n"
ls -lah /home/pxeadmin/pxe_root