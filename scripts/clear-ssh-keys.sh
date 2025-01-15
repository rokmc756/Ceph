
IPs="61 62 63 64 65 71 72 73"

for eIP in `echo $IPs`
do
    echo $eIP

    sshpass -p "changeme" ssh -o StrictHostKeyChecking=no root@192.168.1.$eIP "rm -f /root/.ssk/* /home/jomoon/.ssh/* /home/cephadm/.ssh/*"

done

