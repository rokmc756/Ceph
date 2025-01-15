systemctl stop ceph-mon.target
systemctl stop ceph-mgr.target
systemctl stop ceph-mds.target
systemctl stop ceph-osd.target

##################################################################
rm -rf /etc/systemd/system/ceph*
systemctl daemon-reload

killall -9 ceph-mon ceph-mgr ceph-mds
rm -rf /var/lib/ceph/mon/  /var/lib/ceph/mgr/  /var/lib/ceph/mds/
pveceph purge

apt purge ceph-mon ceph-osd ceph-mgr ceph-mds
apt purge ceph-base ceph-mgr-modules-core
rm -rf /etc/ceph/*
rm -rf /etc/pve/ceph.conf
rm -rf /etc/pve/priv/ceph.*

