#!/bin/bash

function install_public_keys {
rootfs_path=$1

  # install the public keys for the host machine to the container as well
  if [ -f /root/.ssh/authorized_keys ]
  then
    mkdir -p $rootfs_path/root/.ssh
    cat /root/.ssh/authorized_keys >> $rootfs_path/root/.ssh/authorized_keys
    chmod -R 600 $rootfs_path/root/.ssh/authorized_keys
  fi

  # install the public key for local root login
  if [ -f /root/.ssh/id_rsa.pub ]
  then
    # add a newline
    mkdir -p $rootfs_path/root/.ssh
    echo >> $rootfs_path/root/.ssh/authorized_keys
    cat /root/.ssh/id_rsa.pub >> $rootfs_path/root/.ssh/authorized_keys
    chmod -R 600 $rootfs_path/root/.ssh/authorized_keys
  fi
}

function configure_autostart {
autostart=$1
name=$2

  if [ $autostart -eq 1 ]
  then
    lxc config set $name boot.autostart true
  else
    lxc config set $name boot.autostart false
  fi
}

die() {
msg=$1
   echo "$msg"
   exit -1
}

function info {
cid=$1
name=$2
IPv4=$3

  echo To setup port forwarding from outside, please run:
  echo ./tunnelport.sh $cid 22
  echo ./initWebproxy.sh $cid www.$name.de
  echo
  echo To start the container, run: lxc-start -d -n $name
  echo
  echo "To connect to the container locally, run: eval \`ssh-agent\`; ssh-add; ssh root@$IPv4"

}

function getOutwardInterface {
  local interface=eth0
  # interface can be eth0, or p10p1, etc
  if [ -f /etc/network/interfaces ]
  then
    interface=`cat /etc/network/interfaces | grep "auto" | grep -v "auto lo" | awk '{ print $2 }'`
  fi
  if [ -z $interface ]
  then
    interface=`ip route|grep default | head -n 1 | awk '{print $8}'`
  fi
  bionic=`cat /etc/lsb-release  | grep bionic`
  if [ ! -z $bionic ]
  then
    # Ubuntu Bionic
    interface=`ip route|grep default | head -n 1 | awk '{print $5}'`
  fi
  echo $interface
}

function getBridgeInterface {
  echo "lxdbr0"
}

function getIPOfInterface {
interface=$1
  echo "10.0.4.1"
}

function getOSOfContainer {
rootfs=$1
  if [ -f $rootfs/etc/redhat-release ]
  then
    # CentOS
    version="`cat $rootfs/etc/redhat-release`"
  elif [ -f $rootfs/etc/lsb-release ]
  then
    # Ubuntu
    . $rootfs/etc/lsb-release
    version="$DISTRIB_DESCRIPTION"
  elif [ -f $rootfs/etc/debian_version ]
  then
    # Debian
    version="Debian `cat $rootfs/etc/debian_version`"
  fi

  # remove release and Linux
  tmp="${version/Linux/}"
  tmp="${tmp/release/}"
  OS=`echo $tmp | awk '{print $1}'`
  OSRelease=`echo $tmp | awk '{print $2}'`
  if [[ "$OS" == "Ubuntu" ]]
  then
    OSRelease=`echo $OSRelease | awk -F. '{print $1 "." $2}'`
  else
    OSRelease=`echo $OSRelease | awk -F. '{print $1}'`
  fi
}
