for i in `seq 7 7`
do

    ssh root@192.168.1.17$i "mount -l | grep -E 'nfs|smb|ceph|iscsi'"

done

# for i in `find ./ -name "*2023-03-21*.csv"`; do grep --with-filename -E 'FATAL\:|ERROR\:' $i; done

