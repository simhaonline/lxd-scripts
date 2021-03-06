#!/bin/bash

SCRIPTSPATH=`dirname ${BASH_SOURCE[0]}`
source $SCRIPTSPATH/lib.sh

if [ -z $3 ]
then
  echo "please call $0 <hostpath> <containername> <localpath>"
  exit 1
fi

hostpath=$1
containername=$2
localpath=$3
rootfs_path=$container_path/$containername/rootfs
relativepath=${localpath:1}
containerpath=${rootfspath}/$relativepath
mountname="${relativepath//\//_}"

rm -Rf $containerpath
mkdir -p $containerpath

# see https://stgraber.org/2017/06/15/custom-user-mappings-in-lxd-containers/
# you will only be able to write to the mounted directory, if it allows writing for other.
# it will be owned by user and group nobody, uid 65534
# see https://discuss.linuxcontainers.org/t/mount-a-folder-in-host-into-lxd-container-nogroup-nobody-in-the-container/6341
mkdir -p $hostpath
chmod -R a+rwx $hostpath
chown -R 100000.100000 $hostpath

lxc config device add $containername $mountname disk source=$hostpath/ path=$localpath
