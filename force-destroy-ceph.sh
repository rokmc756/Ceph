#!/bin/bash
#
# https://www.flamingbytes.com/blog/how-to-uninstall-ceph-storage-cluster/
### Check the pools, images and OSDs
# ceph osd tree
# $ ceph osd lspools
# 1 device_health_metrics
# 2 datapool

# $ rbd showmapped
# id  pool      namespace  image    snap  device
# 0   datapool             rbdvol1  -     /dev/rbd0
# 1   datapool             rbdvol2  -     /dev/rbd1
# 2   datapool             rbdvol3  -     /dev/rbd2
# 3   datapool             rbdvol4  -     /dev/rbd3

### Remove the images and pools
# rbd unmap /dev/rbd0
# rbd unmap /dev/rbd1
# rbd unmap /dev/rbd2
# rbd unmap /dev/rbd3

# rbd showmapped
# rbd rm datapool/rbdvol1
# rbd rm datapool/rbdvol2
# rbd rm datapool/rbdvol3
# rbd rm datapool/rbdvol4

# ceph osd pool rm datapool datapool --yes-i-really-really-mean-it
# Error EPERM: pool deletion is disabled; you must first set the mon_allow_pool_delete config option to true before you can destroy a pool

# ceph tell mon.\* injectargs '--mon-allow-pool-delete=true'
# ceph osd pool rm datapool datapool --yes-i-really-really-mean-it


# Remove the OSDs
for i in $(seq 0 8)
do
    cephadm shell -- ceph osd down $i && cephadm shell -- ceph osd destroy $i --force
done

### Remove the cluster hosts for mon and check if there is ceph daemon running
for i in `echo "01 02 03"`
do

    cephadm shell -- ceph orch host rm rk9-node$i
    cephadm shell -- ceph orch host drain rk9-node$i
    cephadm shell -- ceph orch ps rk9-node$i

done

### Remove the ceph storage cluster
FSID=$(/root/cephadm ls | grep fsid | uniq | awk '{print $2}' | sed -e "s/\"//g" | cut -d , -f 1)
cephadm rm-cluster --fsid $FSID --force
cephadm ls

### Cleanup the ceph configuration files
# rm -rf /etc/ceph
# rm -rf /var/lib/ce
# ceph/       cephadm/    certmonger/
# rm -rf /var/lib/ceph*

#for i in `echo "01 02 03"`
#do
#    cephadm shell -- ceph orch host rm rk9-node$i
#    cephadm shell -- ceph orch host drain rk9-node$i
#    cephadm shell -- ceph orch ps rk9-node$i
#done

# for i in {01..03}
for i in `echo "04 05 06"`
do

    killall conmon
    killall podman
    sshpass -p "changeme" ssh -o StrictHostKeyChecking=no root@rk9-node$i "dnf -y remove ceph-conmon *podman* ceph-radosgw"
    # ssh root@rk9-node$i "for j in \$(echo 'sdb sdc sdd'); do wipefs -a /dev/\$j; done"
    # ssh root@rk9-node$i "for j in \$(echo 'sdb sdc sdd'); do dd if=/dev/zero of=/dev/\$j bs=512 count=1; done"

done

for i in `echo "01 02 03 04 05 06"`
do

    # Cleanup the ceph configuration files
    sshpass -p "changeme" ssh -o StrictHostKeyChecking=no root@rk9-node$i "rm -rf /etc/ceph"
    sshpass -p "changeme" ssh -o StrictHostKeyChecking=no root@rk9-node$i "rm -rf /var/lib/ceph*"

    # Cleanup the ceph block devices
    sshpass -p "changeme" ssh -o StrictHostKeyChecking=no root@rk9-node$i "lsblk"

done

# for i in {01..03}
for i in `echo "01 02 03"`
do

    killall conmon
    killall podman
    sshpass -p "changeme" ssh -o StrictHostKeyChecking=no root@rk9-node$i "dnf remove -y ceph-conmon *podman* ceph-radosgw"
    # ssh root@rk9-node$i "for j in \$(echo 'sdb sdc sdd'); do wipefs -a /dev/\$j; done"
    # ssh root@rk9-node$i "for j in \$(echo 'sdb sdc sdd'); do dd if=/dev/zero of=/dev/\$j bs=512 count=1; done"

done


for i in `echo "06 05 04 03 02 01"`
do

    # Cleanup the ceph block devices
    sshpass -p "changeme" ssh -o StrictHostKeyChecking=no root@rk9-node$i "reboot"

done

