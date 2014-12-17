#!/bin/bash

echo "updating the host " `hostname -f`
apt-get update && apt-get -y upgrade --force-yes

for d in /var/lib/lxc/*
do
  echo "updating " `basename $d`
  rootfs=$d/rootfs
  if [ -f $rootfs/etc/redhat-release ]
  then
    # CentOS
    chroot $rootfs bash -c 'yum -y update'
  elif [ -f $rootfs/etc/lsb-release ]
  then
    # Ubuntu
    chroot $rootfs bash -c 'apt-get update && apt-get -y upgrade --force-yes'
  elif [ -f $rootfs/etc/debian_version ]
  then
    # Debian
    chroot $rootfs bash -c 'apt-get update && apt-get -y upgrade --force-yes'
  fi
done
