# Disconnect the NVMe-oF initiator from NVMe-oF target.
nvme disconnect-all

# VMware esx initiator
# esxcli nvme disconnect -n CONTROLLER_NUMBER -a NVME_TCP_ADAPTER -s SUBSYSTEM_NQN

# where CONTROLLER_NUMBER is the number that is fetched from esxcli nvme namespace list command, NVME_TCP_ADAPTER and SUBSYSTEM_NQN are values from the esxcli nvme fabrics connect command.
# Remove NVMe-oF Gateway target.
# Remove existing namespace from subsystem.
# podman run -it <cp.icr.io/cp/ibm-ceph/nvmeof-cli-rhel9:latest> --server-address GATEWAY_IP --server-port 5500 remove_namespace -n SUBSYSTEM_NQN -i NSID
# For example,
podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 namespace del --subsystem nqn.2016-06.io.spdk:rk9-node01 --nsid 1
# Failure deleting namespace: Can't find namespace

# Delete bdevs created on target.
# podman run -it <cp.icr.io/cp/ibm-ceph/nvmeof-cli-rhel9:latest> --server-address GATEWAY_IP --server-port 5500 delete_bdev -b BLOCK_DEVICE_NAME
# For example,
# podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 delete_bdev -b nvmeof_pool01_01
ceph orch rm nvmeof.nvmeof_pool01

# Removed service nvmeof.nvmeof_pool01
ceph config set mon mon_allow_pool_delete true

ceph osd pool rm nvmeof_pool01 nvmeof_pool01 --yes-i-really-really-mean-it
# pool 'nvmeof_pool01' removed


# Here
# ###################################################


# Delete subsystem created on target.
# podman run -it <cp.icr.io/cp/ibm-ceph/nvmeof-cli-rhel9:latest> --server-address GATEWAY_IP --server-port 5500 delete_subsystem -n SUBSYSTEM_NQN
# For example,
podman run -it quay.io/ceph/nvmeof-cli:latest --server-address 192.168.1.71 --server-port 5500 delete_subsystem -n nqn.2016-06.io.spdk:rk9-node01


# Remove NVMe-oF service.
# On the Ceph admin node, remove the NVMe-oF service.
# ceph orch rm nvmeof.NVME-OF_POOL_NAME
# For example,
ceph orch rm nvmeof.nvmeof_pool01

# Ensure that the mon_allow_pool_delete parameter is set to true
ceph config set mon mon_allow_pool_delete true

# On the Ceph admin node, remove the NVME-OF_POOL created to host NVMe-oF service.
# ceph osd pool rm NVME-OF_POOL_NAME NVME-OF_POOL_NAME --yes-i-really-really-mean-it
# Note: You need to use the pool name NVME-OF_POOL_NAME twice in the command to remove the pool.
# For example,
ceph osd pool rm nvmeof_pool01 nvmeof_pool01 --yes-i-really-really-mean-it

