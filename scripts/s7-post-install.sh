#!/bin/bash
# Copyright (C) 2025 Maged Mokhtar <mmokhtar <at> petasan.org>
# Copyright (C) 2025 PetaSAN www.petasan.org


# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.



SLEEP_SEC=3


# -------  inline patches (should be before chroot) -------------


#patch -p1 --forward -d  /mnt/rootfs  <<'EOF'
#--- a/usr/lib/python3/dist-packages/dialog.py
#+++ b/usr/lib/python3/dist-packages/dialog.py
#@@ -1202,10 +1202,7 @@ class Dialog:
#         l = ['"']
# 
#         for c in argument:
#-            if c in ('"', '\\'):
#-                l.append("\\" + c)
#-            else:
#-                l.append(c)
#+            l.append(c)
# 
#         return ''.join(l + ['"'])
#EOF


# udev data for udevadm info data
mkdir -p /mnt/rootfs/run/udev/data
mount --bind /run/udev/data  /mnt/rootfs/run/udev/data

chroot /mnt/rootfs /bin/bash  << 'EOF'


# -------  service start -------------
# base
systemctl disable apache2
systemctl disable carbon-cache
systemctl disable collectd
systemctl disable ctdb
systemctl disable grafana-server
systemctl disable glusterd
systemctl disable glustereventsd
systemctl disable nginx
systemctl disable nmbd
update-rc.d ntp disable
systemctl disable ntp
systemctl disable smartd
systemctl disable smartmontools
systemctl disable smbd
systemctl disable sysstat
systemctl disable systemd-timesyncd
systemctl disable winbind

# ceph
systemctl disable ceph.target
systemctl disable ceph-mon.target
systemctl disable ceph-mgr.target
systemctl disable ceph-mds.target
systemctl disable ceph-crash
useradd -d /home/ceph -m ceph

# petasan
# disable all except petasan-console, petasan-deploy, petasan-start-services

systemctl disable petasan-admin
systemctl disable petasan-cifs
systemctl disable petasan-cluster-leader
systemctl enable petasan-console
systemctl enable petasan-deploy
systemctl disable petasan-file-sync
systemctl disable petasan-iscsi-export-snap
systemctl disable petasan-iscsi
systemctl disable petasan-mount-sharedfs
systemctl disable petasan-nfs-exports@
systemctl disable petasan-nfs-server
systemctl disable petasan-node-stats
systemctl disable petasan-notification
systemctl disable petasan-osd-gradual-capacity
systemctl disable petasan-qperf
systemctl disable petasan-s3
systemctl disable petasan-snapshots
systemctl disable petasan-start-osds
systemctl enable petasan-start-services
systemctl disable petasan-sync-replication-node
systemctl disable petasan-tuning-cluster-server
systemctl disable petasan-tuning-host-server
systemctl disable petasan-update-node-info


# -------  configure repositories -------------

cat << EOF2    >  /etc/apt/sources.list

# PetaSAN updates
deb http://archive.petasan.org/repo_v4/  petasan-v4 updates

# main
deb http://archive.ubuntu.com/ubuntu/ jammy main 
deb http://archive.ubuntu.com/ubuntu/ jammy-updates main 
deb http://archive.ubuntu.com/ubuntu/ jammy-security main 

# universe
deb http://archive.ubuntu.com/ubuntu/ jammy universe
deb http://archive.ubuntu.com/ubuntu/ jammy-updates universe
deb http://archive.ubuntu.com/ubuntu/ jammy-security universe

# multiverse universe
#deb http://archive.ubuntu.com/ubuntu/ jammy multiverse
#deb http://archive.ubuntu.com/ubuntu/ jammy-updates multiverse
#deb http://archive.ubuntu.com/ubuntu/ jammy-security multiverse

EOF2

# set priority
cat << EOF2  >  /etc/apt/preferences.d/90-petasan
Package: *
Pin: release o=PetaSAN
Pin-Priority: 700
EOF2

# -------  config fixes -------------

# graphite ubuntu 22.04
ln -s /etc/graphite/local_settings.py /usr/lib/python3/dist-packages/graphite/local_settings.py

# SSH configuration 
update-rc.d ssh defaults 
# server
mkdir -p /run/sshd
sed -i -- 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g'  /etc/ssh/sshd_config
echo "UseDNS no" >>  /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >>  /etc/ssh/sshd_config
# client
sed -i -- 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g'  /etc/ssh/ssh_config
echo "ServerAliveInterval 5 " >>  /etc/ssh/ssh_config
echo "ServerAliveCountMax 2 " >>  /etc/ssh/ssh_config

# console fonts
sed -i -- 's/FONTFACE=\"VGA\"/FONTFACE=\"Fixed\"/g'  /etc/default/console-setup

# logrotate
mv /etc/cron.daily/logrotate /etc/cron.hourly
sed -i '5 i maxsize 100M\nminsize 100M\n' /etc/logrotate.conf

cat << EOF2  >  /etc/logrotate.d/syslog
/var/log/syslog{
su root syslog
rotate 3
size 1G
compress
delaycompress
missingok
}
EOF2


# -------  petasan setup  -------------

mkdir -p /opt/petasan/config/shared
mkdir -p /opt/petasan/config/gfs-brick

ln -s /opt/petasan/scripts/cron-1h.py /etc/cron.hourly/cron-1h
ln -s /opt/petasan/scripts/cron-1d.py /etc/cron.daily/cron-1d

mkdir -p     /opt/petasan/log
touch        /opt/petasan/log/PetaSAN.log
chmod 777    /opt/petasan/log/PetaSAN.log
mkdir -p     /opt/petasan/jobs
chmod -R 777 /opt/petasan/jobs
mkdir -p     /opt/petasan/config/crush/backup
chmod -R 777 /opt/petasan/config/crush/backup
mkdir -p     /opt/petasan/config/replication
chmod -R 777 /opt/petasan/config/replication


# -------  create sym links of config files  -------------

mkdir -p /opt/petasan/config/etc/ceph
rm -rf /etc/ceph
ln -s /opt/petasan/config/etc/ceph /etc/ceph

mkdir -p /opt/petasan/config/etc
cp /etc/hosts /opt/petasan/config/etc
rm -f /etc/hosts
ln -s /opt/petasan/config/etc/hosts /etc/hosts

cp -r /etc/ssh /opt/petasan/config/etc
rm -rf /etc/ssh
ln -s /opt/petasan/config/etc/ssh /etc/ssh

if [ -d /root/.ssh  ]; then
  mkdir -p /opt/petasan/config/root
  cp -r  /root/.ssh /opt/petasan/config/root
  rm -rf /root/.ssh
else
  mkdir -p /opt/petasan/config/root/.ssh
fi
ln -s /opt/petasan/config/root/.ssh /root/.ssh

mkdir -p /opt/petasan/config/etc/network
cp -f /etc/network/interfaces /opt/petasan/config/etc/network
rm -f /etc/network/interfaces
ln -s /opt/petasan/config/etc/network/interfaces  /etc/network/interfaces

cp /etc/resolv.conf /opt/petasan/config/etc
rm -f /etc/resolv.conf
ln -s /opt/petasan/config/etc/resolv.conf /etc/resolv.conf

cp /etc/ntp.conf /opt/petasan/config/etc
rm -f /etc/ntp.conf
ln -s /opt/petasan/config/etc/ntp.conf /etc/ntp.conf

readlink /etc/localtime  > /opt/petasan/config/etc/tz

mkdir -p /opt/petasan/config/var/lib
cp -rf /var/lib/glusterd  /opt/petasan/config/var/lib
rm -rf /var/lib/glusterd
ln -s /opt/petasan/config/var/lib/glusterd /var/lib/glusterd


# sym links do not work for these, just keep a copy in config
cp  /etc/hostname /opt/petasan/config/etc/hostname
cp /etc/passwd /opt/petasan/config/etc
cp /etc/shadow /opt/petasan/config/etc


# persistent_net_rules
/opt/petasan/scripts/installer/persistent_net_rules.py


# 75-persistent-net-generator.rules
cat << 'EOF2'  >  /etc/udev/rules.d/75-persistent-net-generator.rules

SUBSYSTEM!="net", GOTO="persistent_net_generator_end"
ACTION!="add", GOTO="persistent_net_generator_end"
NAME=="?*", GOTO="persistent_net_generator_end"
KERNEL!="eth*|en*|wlan*", GOTO="persistent_net_generator_end"
DRIVERS=="?*", IMPORT{program}="/opt/petasan/scripts/util/if-name-generator.py $attr{address} %k "
ENV{PS_INTERFACE_NAME}=="?*", NAME="$env{PS_INTERFACE_NAME}"
LABEL="persistent_net_generator_end"

EOF2


# /etc/initramfs-tools/hooks/petasan
mkdir -p /etc/initramfs-tools/hooks

cat << 'EOF2'  >  /etc/initramfs-tools/hooks/petasan
#!/bin/sh

PREREQ="udev"

prereqs () {
	echo "${PREREQ}"
}

case "${1}" in
	prereqs)
		prereqs
		exit 0
		;;
esac

. /usr/share/initramfs-tools/hook-functions

rm "$DESTDIR/lib/udev/rules.d/70-persistent-net.rules"  > /dev/null 2>&1
rm "$DESTDIR/lib/udev/rules.d/75-persistent-net-generator.rules"  > /dev/null 2>&1
rm "$DESTDIR/lib/systemd/network/10-petasan-"*.link > /dev/null 2>&1

exit 0

EOF2

chmod +x /etc/initramfs-tools/hooks/petasan
update-initramfs -u

#sed -i 's/ifnames=0/ifnames=1/g' /etc/default/grub
#update-grub

EOF

sync
sleep $SLEEP_SEC

umount /mnt/efi > /dev/null 2>&1
umount /mnt/rootfs/sys > /dev/null 2>&1
umount /mnt/rootfs/proc > /dev/null 2>&1
umount /mnt/rootfs/dev > /dev/null 2>&1
umount /mnt/rootfs/run/udev/data > /dev/null 2>&1
umount /mnt/rootfs/ > /dev/null 2>&1


