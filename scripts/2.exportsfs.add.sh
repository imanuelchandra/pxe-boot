#!/bin/bash

exports="/config/exports"

if [ ! -r "$exports" ]; then
    echo "Please ensure '$exports' exists and is readable."
    exit 1
else
    sudo rm /etc/exports
    sudo cp $exports /etc/exports
    echo "===================================\n"
    sudo echo "File /etc/exports....\n"
    echo "===================================\n"
    sudo cat /etc/exports
    echo "\n"
fi