


for i in `seq 1 3`
do

    sshpass -p "changeme" ssh -o StrictHostKeyChecking=no \
    root@192.168.0.7$i \
"podman ps | grep ceph | grep tcmu | awk '{print\" \"\$NF}' | tr -d '^[:blank:]'"

done

# podman_iscsi_gw_cmd: "podman exec -it {{ iscsi_gw_cont_id.stdout }}"
# [root@rk9-node01 ~]# podman ps | grep ceph | grep tcmu | awk '{print" "$NF}' | tr -d '^[:blank:]'
