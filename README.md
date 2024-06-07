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
* CentOS/Rocky Linux 9.x and OpenSUSE 15.x

## Prerequisite
* MacOS or Fedora/CentOS/RHEL should have installed ansible as ansible host.
* Supported OS for ansible target host should be prepared with package repository configured such as yum, dnf and apt

## Prepare ansible host to run vmware-postgres ansible playbook
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
rk9-node03 ansible_ssh_host=192.168.0.73

[mon]
rk9-node01 ansible_ssh_host=192.168.0.71
rk9-node02 ansible_ssh_host=192.168.0.72
rk9-node03 ansible_ssh_host=192.168.0.73

[osd]
rk9-node04 ansible_ssh_host=192.168.0.74
rk9-node05 ansible_ssh_host=192.168.0.75
rk9-node06 ansible_ssh_host=192.168.0.76

[clients]
ubt22-client01 ansible_ssh_host=192.168.0.61
ubt22-client02 ansible_ssh_host=192.168.0.62
ubt22-client03 ansible_ssh_host=192.168.0.63
```

#### 03) Configure variables for deploying Ceph
```
$ vi roles/init-hosts/vars/main.yml
ansible_ssh_pass: "changeme"
ansible_become_pass: "changeme"
sudo_user: "cephadm"
sudo_group: "cephadm"
local_sudo_user: "jomoon"
rh_wheel_group: "wheel"     # RHEL / CentOS / Rocky
ubt_wheel_group: "sudo"    # Debian / Ubuntu
root_user_pass: "changeme"
sudo_user_pass: "changeme"
sudo_user_home_dir: "/home/{{ sudo_user }}"
domain_name: "jtest.weka.io"

$ vi group_vars/all.yml
ansible_ssh_pass: "changeme"
ansible_become_pass: "changeme"
~~ snip
cephadm:
  major_version: 18
  minor_version: 2
  patch_version: 1
  base_path: /usr/sbin  # /root # RedHat
  bin_type: tar.gz
  download: false

ceph:
  control_node: "{{ hostvars[groups['mon'][0]]['ansible_hostname'] }}"
  cluster_name: jack-kr-ceph
  major_version: "18"
  minor_version: "2"
  build_version: "1"
  patch_version: ""
  download_url: ""
  download: false
  base_path: /root
  admin_user: admin
  admin_passwd: changeme
  bin_type: tar
~~ snip
```

### 04) - Initialize Linux Hosts
- Initialize linux hosts in order to prepare deploy ceph cluster by ansible such as creating users, exchanging ssh keys and configure /etc/hosts in all hosts.
```
$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
~~ snip
  roles:
    - { role: init-hosts }

$ make install
```
[![YouTube](http://i.ytimg.com/vi/1BEf_Hntagk/hqdefault.jpg)](https://www.youtube.com/watch?v=1BEf_Hntagk)


### 05) Install Ceph Software into all Hosts.
```
$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
    upload_cephadm: true
    install_ceph: true
  roles:
    - { role: ceph }

$ make install
```
[![YouTube](http://i.ytimg.com/vi/qeE46zWnbTs/hqdefault.jpg)](https://www.youtube.com/watch?v=qeE46zWnbTs)


### 06) Initialize Ceph as deploying MON and MGR services
```
$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
    init_ceph: true
  roles:
    - { role: ceph }

$ make install
```
[![YouTube](http://i.ytimg.com/vi/2DhiWXthQBU/hqdefault.jpg)](https://www.youtube.com/watch?v=2DhiWXthQBU)


### 07) Add Ceph Nodes for High Availablity
```
$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
    add_ceph_nodes: true
  roles:
    - { role: ceph }

$ make install
```
[![YouTube](http://i.ytimg.com/vi/I2lmJJWNGD8/hqdefault.jpg)](https://www.youtube.com/watch?v=I2lmJJWNGD8)


### 08) Add OSD nodes
```
$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
    add_osd_nodes: true
  roles:
    - { role: ceph }

$ make install
```
[![YouTube](http://i.ytimg.com/vi/6ptuBjDHaCQ/hqdefault.jpg)](https://www.youtube.com/watch?v=6ptuBjDHaCQ)


### 09) Create Pools and RBDs
```
$ vi group_vars/all.yml
~~ snip
ceph:
  control_node: "{{ hostvars[groups['mon'][0]]['ansible_hostname'] }}"
  cluster_name: jack-kr-ceph
  major_version: "18"
  minor_version: "2"
  build_version: "1"
~~ snip
  block:
    rbd: true
    iscsi: false
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: block }

$ make install
```
[![YouTube](http://i.ytimg.com/vi/imcsu2QF3io/hqdefault.jpg)](https://www.youtube.com/watch?v=imcsu2QF3io)


### 10) Creating Ceph Filesystems and CephFS POSIX Clients
```
$ vi group_vars/all.yml
~~ snip
ceph:
  control_node: "{{ hostvars[groups['mon'][0]]['ansible_hostname'] }}"
  cluster_name: jack-kr-ceph
  major_version: "18"
  minor_version: "2"
  build_version: "1"
~~ snip
  obs: false
  fs: true
~~ snip
~~ snip
  client:
    cephfs: true
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: cephfs }

$ make install
```
[![YouTube](http://i.ytimg.com/vi/x6z-ErtC7Ho/hqdefault.jpg)](https://www.youtube.com/watch?v=x6z-ErtC7Ho)


### 11) Deploy Multisite Rados Gateway
~~~
$ vi group_vars/all.yml
~~ snip
  protocol:
~~ snip
    rgw:
      single: false
      multi: true
  client:
~~ snip
    rgw:
      single: false
      multi: true
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: radosgw }

$ make install
~~~
[![YouTube](http://i.ytimg.com/vi/kblAiF7r0a0/hqdefault.jpg)](https://www.youtube.com/watch?v=kblAiF7r0a0)


### 12) Destroy Multisite Rados Gateway
~~~
$ vi group_vars/all.yml
~~ snip
  protocol:
~~ snip
    rgw:
      single: false
      multi: true
  client:
~~ snip
    rgw:
      single: false
      multi: true
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: radosgw }

$ make install
~~~
[![YouTube](http://i.ytimg.com/vi/138Y5FPVmjA/hqdefault.jpg)](https://www.youtube.com/watch?v=138Y5FPVmjA)


### 13) Deploy NFS Ganesha Cluster with a RGW
~~~
$ vi group_vars/all.yml
~~ snip
  protocol:
    nfs:
      single: false
      ganesha: true
    rgw:
      single: true
      multi: false
  client:
~~ snip
    nfs:
      single: false
      ganesha: true
    rgw:
      single: true
      multi: false
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: radosgw }
    - { role: nfs }

$ make install
~~~
[![YouTube](http://i.ytimg.com/vi/e5sEYsm9u5Q/hqdefault.jpg)](https://www.youtube.com/watch?v=e5sEYsm9u5Q)


### 14) Destory NFS Ganesha Cluser with single RGW
~~~
$ vi group_vars/all.yml
~~ snip
  protocol:
    nfs:
      single: false
      ganesha: true
    rgw:
      single: true
      multi: false
  client:
~~ snip
    nfs:
      single: false
      ganesha: true
    rgw:
      single: true
      multi: false
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: nfs }
    - { role: radosgw }

$ make install
~~~
[![YouTube](http://i.ytimg.com/vi/cUFCWH0EMGY/hqdefault.jpg)](https://www.youtube.com/watch?v=cUFCWH0EMGY)


### 15) Deploy Single NFS Service
~~~
$ vi group_vars/all.yml
~~ snip
  protocol:
~~ snip
    nfs:
      single: true
      ganesha: false
~~ snip
  client:
~~ snip
    nfs:
      single: true
      ganesha: false
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: nfs }

$ make install
~~~
[![YouTube](http://i.ytimg.com/vi/A0yBCh9-w7c/hqdefault.jpg)](https://www.youtube.com/watch?v=A0yBCh9-w7c)


### 16) Destroy Single NFS Service
~~~
$ vi group_vars/all.yml
~~ snip
  protocol:
~~ snip
    nfs:
      single: true
      ganesha: false
~~ snip
  client:
~~ snip
    nfs:
      single: true
      ganesha: false
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: nfs }

$ make install
~~~
[![YouTube](http://i.ytimg.com/vi/dBvBt9ox8kY/hqdefault.jpg)](https://www.youtube.com/watch?v=dBvBt9ox8kY)


### 17) Deploy iSCSI Gateways and iSCSI Clients
~~~
$ vi group_vars/all.yml
  block:
    rbd: true
    iscsi: false
~~ snip
  client:
~~ snip
    block:
      rbd: false
      iscsi: true
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: block }

$ make install
~~~
[![YouTube](http://i.ytimg.com/vi/424LwFCZwjg/hqdefault.jpg)](https://www.youtube.com/watch?v=424LwFCZwjg)


### 18) Destroy iSCSI Clients and Gateways
~~~
$ vi group_vars/all.yml
  block:
    rbd: true
    iscsi: false
~~ snip
  client:
~~ snip
    block:
      rbd: false
      iscsi: true
~~ snip

$ vi install.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
  roles:
    - { role: block }

$ make install
~~~
[![YouTube](http://i.ytimg.com/vi/wunlKs8cLug/hqdefault.jpg)](https://www.youtube.com/watch?v=wunlKs8cLug)

* Test
ifdef::env-github[]
image: http://i.ytimg.com/vi/wunlKs8cLug/hqdefault.jpg[link=https://www.youtube.com/watch?v=wunlKs8cLug]
endif::[]

ifndef::env-github[]
video::wunlKs8cLug[youtube]
endif::[]


## High Availability Service for RGW
<img src="https://github.com/rokmc756/Ceph/blob/main/roles/ceph/files/haroxy_for_rgw.svg" width="80%" height="80%" align="center"></img>

## YouTube Video Demo
* Links has been generated by https://githubvideo.com

## References
- https://cray-hpe.github.io/docs-csm/en-10/operations/utility_storage/manage_ceph_services/
- https://www.server-world.info/en/note?os=Ubuntu_20.04&p=ceph15&f=1
- https://kifarunix.com/how-to-deploy-ceph-storage-cluster-on-rocky-linux/?expand_article=1
- https://kifarunix.com/install-docker-on-rocky-linux/?expand_article=1
- https://www.flamingbytes.com/blog/how-to-uninstall-ceph-storage-cluster/
- https://gist.github.com/fmount/6203013d1c423dd831e3717b9986551b
- https://www.ibm.com/docs/en/storage-ceph/5?topic=mcog-deploying-ceph-object-gateway-using-command-line-interface
- https://docs.ceph.com/en/latest/install/get-packages/
- https://vineetcic.medium.com/how-to-remove-add-osd-from-ceph-cluster-1c038eefe522
- https://www.ibm.com/docs/en/storage-ceph/5?topic=osds-deploying-ceph-all-available-devices
- https://serverfault.com/questions/1117213/why-is-ceph-is-not-detecting-ssd-device-on-a-new-node
- https://docs.huihoo.com/ceph/v0.80.5/rados/operations/add-or-rm-osds/index.html
- https://www.ibm.com/docs/en/storage-ceph/5?topic=crush-adding-osd
- https://docs.ceph.com/en/latest/rados/operations/add-or-rm-osds/
- https://medium.com/@avmor/how-to-configure-rgw-multisite-in-ceph-65e89a075c1f
- https://medium.com/@arslankhanali/ceph-setup-rados-gateway-with-multi-site-replication-b158ee5c0e86
- https://www.symmcom.com/docs/how-tos/storages/how-to-configure-s3-compatible-object-storage-on-ceph
- https://docs.ceph.com/en/latest/cephadm/services/smb/
- https://cyuu.tistory.com/145
- https://reintech.io/blog/setting-up-pxe-boot-server-windows-deployment-ubuntu
- https://medium.com/jacklee26/set-up-pxe-server-on-ubuntu20-04-and-window-10-e69733c1de87
- https://blog.zabbix.com/installing-the-zabbix-server-with-ansible/13317/

