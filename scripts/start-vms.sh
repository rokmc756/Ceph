
for i in `sshpass -p "Changeme34#$" ssh -o StrictHostKeyChecking=no root@192.168.0.231 "vim-cmd vmsvc/getallvms | egrep 'vCenter|minio|freeipa|dms-'" | awk '{print $1}' | sort`
do
    echo $i
    sshpass -p "Changeme12!@" ssh -o StrictHostKeyChecking=no root@192.168.0.231 "vim-cmd vmsvc/power.off $i"
    # sshpass -p "Mc002661!@#$" ssh -o StrictHostKeyChecking=no root@192.168.0.101 "vim-cmd vmsvc/power.on 3 7"
done

# sshpass -p "Changeme12!@" ssh -o StrictHostKeyChecking=no root@192.168.0.101 "shutdown.sh && halt"
# sshpass -p "Changeme12!@" ssh -o StrictHostKeyChecking=no root@192.168.0.101 "vim-cmd vmsvc/power.getstate 4"
