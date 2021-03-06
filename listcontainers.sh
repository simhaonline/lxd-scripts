#!/bin/bash

SCRIPTSPATH=/usr/share/lxd-scripts
if [[ "$0" == "./listcontainers.sh" ]]
then
  SCRIPTSPATH=`dirname ${BASH_SOURCE[0]}`
fi
source $SCRIPTSPATH/lib.sh

show="all"
if [[ "$1" == "running" || "$1" == "stopped" ]]
then
  show=$1
fi

tmpfile=/tmp/listcontainers.txt
echo "--" > $tmpfile
echo -e "Name\t IP\t State\t Autostart\t Guest OS" >> $tmpfile
echo "--" >> $tmpfile
for d in $container_path/*
do
  rootfs=$d/rootfs

  if [ ! -d $rootfs ]
  then
    continue
  fi

  name=`basename $d`

  # version=getOSOfContainer
  getOSOfContainer $rootfs

  if [[ -z "`lxc list $name | grep RUNNING`" ]]
  then
    state="stopped"
  else
    state="running"
  fi

  if [[ "true" == "`lxc config get $name boot.autostart`" ]]
  then
    autostart="yes"
  else
    autostart="no"
  fi

  IPv4=`lxc list $name -c 4 --format csv`
  IPv4=`cat $lxdbr0_path/dnsmasq.hosts/$name | awk -F"," '{print $2}'`

  if [[ "$show" == "all" || "$show" == "$state" ]]
  then
    echo -e $name "\t" $IPv4 "\t" $state "\t" $autostart "\t" $version >> $tmpfile
  fi
done

column -t -s $'\t' $tmpfile
rm -f $tmpfile

