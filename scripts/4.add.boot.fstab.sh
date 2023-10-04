#!/bin/bash

# sudo echo "/data /home/pxeadmin/boot fuse.bindfs perms=0000:ug+rwD:u+rD,user=6565,group=6565 0 0" >> /etc/fstab

# sudo cat <<EOF >> /etc/fstab
# /data /home/pxeadmin/boot fuse.bindfs perms=0000:ug+rwD:u+rD,user=6565,group=6565 0 0
# EOF

echo "===================================\n"
echo "Boot Directory FSTAB \n"
echo "===================================\n"
cat /etc/fstab