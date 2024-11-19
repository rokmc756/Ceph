
# Install NVMe-oF Gateway

# OK
ceph osd pool create nvmeof_pool01

# OK
rbd pool init nvmeof_pool01

# OK
ceph orch apply nvmeof nvmeof_pool01 --placement="rk9-node01,rk9-node02,rk9-node03"

# OK
ps axf | grep nvmeof_ | grep conmon


# Define NVMe-oF Subsystem
# https://docs.ceph.com/en/reef/rbd/nvmeof-target-configure/

# OK
podman pull quay.io/ceph/nvmeof-cli:latest


# podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.73 --server-port 5500 subsystem add --subsystem nqn.2016-06.io.spdk:rk9-node03

# OK
podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 subsystem add --subsystem nqn.2016-06.io.spdk:rk9-node01


# podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.73 --server-port 5500 listener add --subsystem nqn.2016-06.io.spdk:rk9-node01 --gateway-name client.nvmeof.nvmeof_pool01.rk9-node03.yzwqgq --traddr 192.168.1.73 --trsvcid 4420

# On the install node, get the NVME-oF Gateway name:
# ceph orch ps | grep nvme | awk '{print $1}'


# OK
podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 listener add --subsystem nqn.2016-06.io.spdk:rk9-node01 \
--host-name rk9-node01 --traddr 192.168.1.81 --trsvcid 4420

#
# --host-name rk9-node06 --traddr 192.168.1.76 --trsvcid 4420
# Failure adding nqn.2016-06.io.spdk:rk9-node03 listener at 192.168.1.76:4420: Gateway's host name must match current host (rk9-node03)
#
# Failure creating subsystem nqn.2016-06.io.spdk:rk9-node03: Subsystem already exists
# Failure adding nqn.2016-06.io.spdk:rk9-node03 listener at 192.168.1.76:4420: Gateway's host name must match current host (rk9-node03)
#
# --gateway-name gw-rk9-node06 
#

# Failure adding nqn.2016-06.io.spdk:rk9-node01 listener at 192.168.1.76:4420: Invalid parameters



# Get the host NQN (NVME Qualified Name) for each host:
cat /etc/nvme/hostnqn

#
# esxcli nvme info get

# Allow the initiator host to connect to the newly-created NVMe subsystem:
# OK
podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 \
host add --subsystem nqn.2016-06.io.spdk:rk9-node01 --host "nqn.2016-06.io.spdk:rk9-node01,nqn.2016-06.io.spdk:rk9-node02,nqn.2016-06.io.spdk:rk9-node03"


# List all subsystems configured in the gateway:
podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 subsystem list

# Create a new NVMe namespace:
# podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 namespace add --subsystem nqn.2016-06.io.spdk:rk9-node01 --rbd-pool nvmeof-pool02 --rbd-image nvmeof-pool02-img01
# podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 namespace add --subsystem nqn.2016-06.io.spdk:rk9-node01 create_bdev --rbd-pool nvmeof-pool01 --rbd-image nvmeof-pool01-01 --bdev ceph-block01
podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 namespace add --subsystem nqn.2016-06.io.spdk:rk9-node01 --rbd-pool nvmeof-pool01 --rbd-image nvmeof-pool01-01 --bdev ceph-block01

