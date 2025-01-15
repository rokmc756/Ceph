
for i in `seq 1 6`
do

    ssh root@rk9-node0$i "echo \$(hostname)"
    # ssh root@rk9-node$i "for j in \$(echo 'sdb sdc sdd'); do dd if=/dev/zero of=/dev/\$j bs=512 count=1; done"
    # ssh root@rk9-node0$i "for j in \$(echo 'sdb sdc sdd'); do wipefs -a /dev/\$j; done"
    ssh root@rk9-node0$i "for j in \$(echo 'nvme0n1 nvme0n2 nvme0n3 nvme0n4'); do wipefs -a /dev/\$j; done"

done
