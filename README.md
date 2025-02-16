## The Ceph Storage Cluster Architecture
<img src="https://github.com/rokmc756/Ceph/blob/main/roles/ceph/files/ceph_vm_architecture.webp" width="100%" height="100%" align="center"></img>

## Terminologies of Ceph Storage
### Ceph Object Storage Daemon (OSD, ceph-osd)
It provides ceph object data store. It also performs data replication, data recovery, rebalancing and provides storage information to Ceph Monitor. At least an OSD is required per storage device.

### Ceph Monitor (ceph-mon)
It maintains maps of the entire Ceph cluster state including monitor map, manager map, the OSD map, and the CRUSH map. Manages authentication between daemons and clients. A Ceph cluster must contain a minimum of three running monitors in order to be both redundant and highly-available.

### Ceph Maanger (ceph-mgr)
Keeps track of runtime metrics and the current state of the Ceph cluster, including storage utilization, current performance metrics, and system load. Manages and exposes Ceph cluster web dashboard and API. At least two managers are required for HA.

### Ceph Metadata Server (MDS)
Manages metadata for the Ceph File System (CephFS). Coordinates metadata access and ensures consistency across clients. One or more, depending on the requirements of the CephFS.

### RADOS Gateway (RGW)
Also called “Ceph Object Gateway” is a component of the Ceph storage system that provides object storage services with a RESTful interface. RGW allows applications and users to interact with Ceph storage using industry-standard APIs, such as the S3 (Simple Storage Service) API (compatible with Amazon S3) and the Swift API (compatible with OpenStack Swift).

### Ceph Storage Cluster Deployment Methods
There are different methods you can use to deploy Ceph storage cluster. The cephadm leverages container technology (specifically, Docker containers) to deploy and manage Ceph services on a cluster of machines. Rook deploys and manages Ceph clusters running in Kubernetes, while also enabling management of storage resources and provisioning via Kubernetes APIs.\
\
ceph-ansible deploys and manages Ceph clusters using Ansible. ceph-salt installs Ceph using Salt and cephadm. jaas.ai/ceph-mon installs Ceph using Juju. Installs Ceph via Puppet. Ceph can also be installed manually. Use of cephadm and rooks are the recommended methods for deploying Ceph storage cluster.

### Ceph Deployment Requirements
Depending on the deployment method you choose, there are different requirements for deploying Ceph storage cluster. In this tutorial, we will use cephadm to deploy Ceph storage cluster on Rocky Linux Below are the requirements for deploying Ceph storage cluster via cephadm; Python 3 (installed by default on Rocky Linux) Systemd Podman or Docker for running containers (we use docker in this setup) Time synchronization (such as chrony or NTP) LVM2 for provisioning storage devices.\
\
We are using raw devices without any filesystem in this guide. All the required dependencies are installed automatically by the bootstrap process.

## Supported Ceph version
* Ceph 18.x and higher versions

## Supported Platform and OS
* Virtual Machines or Baremetal
* CentOS/Rocky Linux 9.x and OpenSUSE 15.x and Ubuntu 22.x

## Prerequisite
* MacOS or Fedora/CentOS/RHEL should have installed ansible as ansible host.
* Supported OS for ansible target host should be prepared with package repository configured such as yum, dnf and apt

## Prepare ansible host to run Ceph Ansible Playbook
* MacOS
```
$ xcode-select --install
$ brew install ansible
$ brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```

* Fedora/CentOS/RHEL
```
$ sudo yum install ansible
```

## Prepareing OS
* Configure Yum / Local & Additional Repostiories

## Download / configure / run Ceph Ansible Playbook
```
$ git clone https://github.com/rokmc756/Ceph
$ cd Ceph
$ vi Makefile
~~ snip
ANSIBLE_HOST_PASS="changeme"    # It should be changed with password of user in ansible host that vmware-postgres would be run.
ANSIBLE_TARGET_PASS="changeme"  # It should be changed with password of sudo user in managed nodes that vmware-postgres would be installed.
~~ snip
```

## How to deploy Ceph Cluster by ansible playbook
#### 01) The Archiecture example to deploy Ceph Storage Cluster
<table border='0'>
<tr><td align='center' border='0'><img src="https://github.com/rokmc756/Ceph/blob/main/roles/ceph/files/ceph_vm_architecture.png" width="100%" height="100%" align="center"></img></td></tr>
</table>

#### 02) Configure inventory for Ceph
```
$ vi ansible-hosts
[all:vars]
ssh_key_filename="id_rsa"
remote_machine_username="jomoon"
remote_machine_password="changeme"


[rgw]
rk9-node03 ansible_ssh_host=192.168.1.173


[primary_rgw]
rk9-node03 ansible_ssh_host=192.168.1.173


[secondary_rgw]
rk9-node06 ansible_ssh_host=192.168.0.176


[control]
rk9-node01 ansible_ssh_host=192.168.1.171


[mon]
rk9-node01 ansible_ssh_host=192.168.1.171
rk9-node02 ansible_ssh_host=192.168.1.172
rk9-node03 ansible_ssh_host=192.168.1.173


[osd]
rk9-node04 ansible_ssh_host=192.168.1.174
rk9-node05 ansible_ssh_host=192.168.1.175
rk9-node06 ansible_ssh_host=192.168.0.176


[clients]
rk9-node07 ansible_ssh_host=192.168.1.177
```

#### 03) Configure variables for deploying Ceph
```
$ vi roles/hosts/vars/main.yml
~~ snip
sudo_user: "cephadm"
sudo_group: "cephadm"
local_sudo_user: "jomoon"
rh_wheel_group: "wheel"            # RHEL / CentOS / Rocky / SUSE / OpenSUSE
ubt_wheel_group: "sudo"            # Debian / Ubuntu
root_user_pass: "changeme"
sudo_user_pass: "changeme"
sudo_user_home_dir: "/home/{{ sudo_user }}"
~~ snip


$ vi group_vars/all.yml
~~ snip
_minio:
  download: false
  client_bin: /usr/local/bin/mc
  client_install: yes
  client_url: https://dl.minio.io/client/mc/release/linux-amd64/mc
  client_checksum:
  release_date: 20240307
~~ snip
_ceph:
  project_name: squid  # reef
  os_version: el9
  domain: "jtest.futurfusion.io"
  rdomain: "io.futurfusion.jtest"
  cluster_name: jack-kr-ceph
  major_version: "19"
  minor_version: "2"
  build_version: "0"
  patch_version: ""
  download_url: ""
  download: false
  base_path: /root
  admin_user: admin
  admin_passwd: changeme
  bin_type: tar
  nvme: true
  mon_host_num: "{{ groups['mon'] | length }}"
  osd_host_num: "{{ groups['osd'] | length }}"
  net:
    conn: "dpdk"                     # dpdk or udp
    gateway: "192.168.2.1"
    ha1: 1
    ha2: 2
    type: "virtual"                  # or physical
    ipaddr0: "192.168.0.7"
    ipaddr1: "192.168.1.7"
    ipaddr2: "192.168.2.7"
  backend:
    net:
      type: "virtual"                # or physical
      ipaddr0: "192.168.0.7"
      ipaddr1: "192.168.1.7"
      ipaddr2: "192.168.2.7"
  client:
    net:
      type: "virtual"                # or physical
      cores: 1
      ipaddr0: "192.168.0.7"
      ipaddr1: "192.168.1.7"
      ipaddr2: "192.168.2.7"
~~ snip
```


### 04) - Initialize or Uninitialize Linux Hosts
- Initialize linux hosts in order to prepare deploy ceph cluster by ansible such as creating users, exchanging ssh keys and configure /etc/hosts in all hosts.
```
$ make hosts r=init s=all
or
$ make hosts r=uninit s=all
```
[![YouTube](http://i.ytimg.com/vi/1BEf_Hntagk/hqdefault.jpg)](https://www.youtube.com/watch?v=1BEf_Hntagk)


### 05) - Enable or Disable Ceph Package Repository
- Enable Ceph Package Repository for Red Hat Based Linux. Ubuntu and SuSE included it as default
```
$ make ceph r=enable s=repo
or
$ make ceph r=disable s=repo
```
[![YouTube](http://i.ytimg.com/vi/1BEf_Hntagk/hqdefault.jpg)](https://www.youtube.com/watch?v=1BEf_Hntagk)


### 06) Upload/Install Ceph Software into All Hosts.
```
$ make ceph r=install s=pkgs
or
$ make ceph r=uninstall s=pkgs
```
[![YouTube](http://i.ytimg.com/vi/qeE46zWnbTs/hqdefault.jpg)](https://www.youtube.com/watch?v=qeE46zWnbTs)


### 07) Initialize/Purge Ceph as Deploying MON and MGR services
```
$ make ceph r=init s=cluster
or
$ make ceph r=purge s=cluster
```
[![YouTube](http://i.ytimg.com/vi/2DhiWXthQBU/hqdefault.jpg)](https://www.youtube.com/watch?v=2DhiWXthQBU)


### 08) Add/Remove Ceph(MGR/MDS/MON) Nodes for High Availablity
```
$ make ceph r=add s=host
$ make ceph r=add s=mgr
$ make ceph r=add s=mds
$ make ceph r=add s=mon
or
$ make ceph r=remove s=mon
$ make ceph r=remove s=mds
$ make ceph r=remove s=mgr
$ make ceph r=remove s=host
```
[![YouTube](http://i.ytimg.com/vi/I2lmJJWNGD8/hqdefault.jpg)](https://www.youtube.com/watch?v=I2lmJJWNGD8)


### 09) Add/Remove OSD nodes
```
$ make ceph r=add s=osd
or
$ make ceph r=remove s=osd
```
[![YouTube](http://i.ytimg.com/vi/6ptuBjDHaCQ/hqdefault.jpg)](https://www.youtube.com/watch?v=6ptuBjDHaCQ)


### 10) Create/Delete Pools and RBDs with RBD Clients
```
$ make block r=create s=pool
$ make block r=create s=rbd
$ make block r=setup  s=rbd c=client     # RBD Client

or
$ make block r=remove s=rbd c=client     # RBD Client
$ make block r=delete s=rbd
$ make block r=delete s=pool
```
[![YouTube](http://i.ytimg.com/vi/imcsu2QF3io/hqdefault.jpg)](https://www.youtube.com/watch?v=imcsu2QF3io)


### 11) Create/Delete Ceph Filesystems and CephFS POSIX Clients
```
$ make cephfs r=create s=pool
$ make cephfs r=create s=fs
$ make cephfs r=setup s=client

or
$ make cephfs r=remove s=client
$ make cephfs r=delete s=fs
$ make cephfs r=delete s=pool
```
[![YouTube](http://i.ytimg.com/vi/x6z-ErtC7Ho/hqdefault.jpg)](https://www.youtube.com/watch?v=x6z-ErtC7Ho)


### 12) Deploy Multisite Rados Gateway
~~~
$ make radosgw r=setup s=multisite
$ make radosgw r=setup s=multisite c=client
~~~
[![YouTube](http://i.ytimg.com/vi/kblAiF7r0a0/hqdefault.jpg)](https://www.youtube.com/watch?v=kblAiF7r0a0)


### 13) Destroy Multisite Rados Gateway
~~~
$ make radosgw r=remove s=multisite c=client
$ make radosgw r=remove s=multisite
~~~
[![YouTube](http://i.ytimg.com/vi/138Y5FPVmjA/hqdefault.jpg)](https://www.youtube.com/watch?v=138Y5FPVmjA)


### 14) Deploy NFS Ganesha Cluster with a RGW
~~~
$ make radosgw r=setup s=single
$ make nfs r=setup s=ganesha
$ make nfs r=setup s=ganesha c=client
~~~
[![YouTube](http://i.ytimg.com/vi/e5sEYsm9u5Q/hqdefault.jpg)](https://www.youtube.com/watch?v=e5sEYsm9u5Q)


### 15) Destory NFS Ganesha Cluser with single RGW
~~~
$ make nfs r=remove s=ganesha c=client
$ make nfs r=remove s=ganesha
$ make radosgw r=remove s=single
~~~
[![YouTube](http://i.ytimg.com/vi/cUFCWH0EMGY/hqdefault.jpg)](https://www.youtube.com/watch?v=cUFCWH0EMGY)


### 16) Deploy Single NFS Service
~~~
$ make nfs r=setup s=single
$ make nfs r=setup s=single c=client
~~~
[![YouTube](http://i.ytimg.com/vi/A0yBCh9-w7c/hqdefault.jpg)](https://www.youtube.com/watch?v=A0yBCh9-w7c)


### 17) Destroy Single NFS Service
~~~
$ make nfs r=remove s=single c=client
$ make nfs r=remove s=single
~~~
[![YouTube](http://i.ytimg.com/vi/dBvBt9ox8kY/hqdefault.jpg)](https://www.youtube.com/watch?v=dBvBt9ox8kY)


### 18) Deploy iSCSI Gateways and iSCSI Clients
~~~
$ make block r=setup s=iscsi
$ make block r=setup s=iscsi c=client
~~~
[![YouTube](http://i.ytimg.com/vi/424LwFCZwjg/hqdefault.jpg)](https://www.youtube.com/watch?v=424LwFCZwjg)


### 19) Destroy iSCSI Clients and Gateways
~~~
$ make block r=remove s=iscsi c=client
$ make block r=remove s=iscsi
~~~
[![YouTube](http://i.ytimg.com/vi/wunlKs8cLug/hqdefault.jpg)](https://www.youtube.com/watch?v=wunlKs8cLug)


## High Availability Service for RGW
<img src="https://github.com/rokmc756/Ceph/blob/main/roles/ceph/files/haroxy_for_rgw.svg" width="80%" height="80%" align="center"></img>

## YouTube Video Demo
* Links has been generated by https://githubvideo.com

## References
- https://cray-hpe.github.io/docs-csm/en-10/operations/utility_storage/manage_ceph_services/
- https://www.server-world.info/en/note?os=Ubuntu_20.04&p=ceph15&f=1
- https://kifarunix.com/how-to-deploy-ceph-storage-cluster-on-rocky-linux/?expand_article=1
- https://www.flamingbytes.com/blog/how-to-uninstall-ceph-storage-cluster/
- https://gist.github.com/fmount/6203013d1c423dd831e3717b9986551b
- https://www.ibm.com/docs/en/storage-ceph/5?topic=mcog-deploying-ceph-object-gateway-using-command-line-interface
- https://docs.ceph.com/en/latest/install/get-packages/
- https://vineetcic.medium.com/how-to-remove-add-osd-from-ceph-cluster-1c038eefe522
- https://docs.huihoo.com/ceph/v0.80.5/rados/operations/add-or-rm-osds/index.html
- https://docs.ceph.com/en/latest/rados/operations/add-or-rm-osds/
- https://medium.com/@avmor/how-to-configure-rgw-multisite-in-ceph-65e89a075c1f
- https://medium.com/@arslankhanali/ceph-setup-rados-gateway-with-multi-site-replication-b158ee5c0e86
- https://docs.ceph.com/en/latest/cephadm/services/smb/
- https://cyuu.tistory.com/145
- https://www.ibm.com/docs/en/storage-ceph/7?topic=preview-removing-nvme-service


## TODO
- [ ] 1. Remove OSD Nodes : Currently there are a few unexpected behavior that removing osd nodes and recreating osd nodes did not create node-exporter.
- [ ] 2. Additionally only osd service is created when readding osd nodes.
- [ ] 3. When readding node-exporter, ceph-exporter, crash service on osd nodes, node-exporter is not fully created that only 1 node-exporter is created.
- [ ] 4. Enable SSL and Use FQDN for Ceph Mgr - https://docs.ceph.com/en/pacific/mgr/dashboard/
- [ ] 5. Create iSCSI Gateways on Ubuntu 22
```
$ vi test.sh

cat << EOF | podman exec -it ceph-ef9ce558-25f6-11ef-915f-c74300a53678-iscsi-jtest-iscsi-pool01-ubt22-node02-gmiiet-tcmu gwcli
cd /iscsi-targets/iqn.2024-04.com.suse.jtest.iscsi-gw:iscsi-igw-ubt22-node02/gateways
create ubt22-node02.jtest.xxx.io 192.168.1.62 skipchecks=true
exit
EOF
```
- [ ] 6. Error to run script with sudo user jomoon. It looks there might need onther cnonfigure for cgroup
$ sh test.sh
```
WARN[0000] The cgroupv2 manager is set to systemd but there is no systemd user session available
WARN[0000] For using systemd, you may need to login using an user session
WARN[0000] Alternatively, you can enable lingering with: `loginctl enable-linger 1000` (possibly as root)
WARN[0000] Falling back to --cgroup-manager=cgroupfs
WARN[0000] XDG_RUNTIME_DIR is pointing to a path which is not writable. Most likely podman will fail.
Error: error creating tmpdir: mkdir /run/user/1000: permission denied
```
- https://superuser.com/questions/1788594/podman-the-cgroupv2-manager-is-set-to-systemd-but-there-is-no-systemd-user-sess
- [ ] 7. Podman Issue
- https://www.server-world.info/en/note?os=Ubuntu_22.04&p=podman&f=12
- https://unix.stackexchange.com/questions/731645/podman-w-docker-compose-run-as-user

