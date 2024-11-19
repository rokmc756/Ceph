
yum install nvme-cli

# On Server Client Bot
modprobe nvme-fabrics

# On Server Client Bot
lsmod | grep nvme

# nvme_fabrics           36864  0
# nvme                   65536  0
# nvme_core             221184  2 nvme,nvme_fabrics
# nvme_common            24576  1 nvme_core
# t10_pi                 24576  2 sd_mod,nvme_core


# On Server
# netstat -anp | grep LISTEN | grep 4420
#tcp        0      0 192.168.1.81:4420       0.0.0.0:*               LISTEN      63493/nvmf_tgt


# nvme discover -t tcp -a 192.168.1.71 -s 4420

nvme connect -t tcp -a 192.168.1.71 -n nqn.2016-06.io.spdk:rk9-node01

nc -v 192.168.1.71 4420

# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_storage_devices/configuring-nvme-over-fabrics-using-nvme-tcp_managing-storage-devices#configuring-an-nvme-tcp-host_configuring-nvme-over-fabrics-using-nvme-tcp
# https://ssdcentral.net/getting-started-with-nvme-over-fabrics-with-tcp/
