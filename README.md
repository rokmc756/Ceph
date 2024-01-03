## The Ceph Storage Cluster Architecture
<img src="https://github.com/rokmc756/Ceph/blob/main/roles/ceph/files/ceph_architecture.webp" width="100%" height="100%" align="center"></img>

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
* Virtual Machines
* Baremetal
* CentOS/Rocky Linux 9.x
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
* Configure Yum / Local & EPEL Repostiory
## Download / configure / run VMware Postgres
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
#### 1) The Archiecture example to deploy Ceph Storage Cluster
<img src="https://github.com/rokmc756/Ceph/blob/main/roles/ceph/files/ceph_vm_architecture.png" width="80%" height="80%" align="center"></img>

#### 2) Configure inventory for Ceph
```
$ vi ansible-hosts
[all:vars]
ssh_key_filename="id_rsa"
remote_machine_username="jomoon"
remote_machine_password="changeme"

[mon]
rk9-ceph-mon01 ansible_ssh_host=192.168.0.221
rk9-ceph-mon02 ansible_ssh_host=192.168.0.222
rk9-ceph-mon03 ansible_ssh_host=192.168.0.223

[osd]
rk9-ceph-osd01 ansible_ssh_host=192.168.0.224
rk9-ceph-osd02 ansible_ssh_host=192.168.0.225
rk9-ceph-osd03 ansible_ssh_host=192.168.0.226
```
#### 3) Configure variables for deploying Ceph
```
$ vi roles/init-hosts/vars/main.yml
ansible_ssh_pass: "changeme"
ansible_become_pass: "changeme"
sudo_user: "ceph"
sudo_group: "ceph"
local_sudo_user: "moonja"
wheel_group: "wheel"     # RHEL / CentOS / Rocky
# wheel_group: "sudo"    # Debian / Ubuntu
root_user_pass: "changeme"
sudo_user_pass: "changeme"
sudo_user_home_dir: "/home/{{ sudo_user }}"
domain_name: "jtest.pivotal.io"

$ vi roles/docker/vars/main.yml
cert_country: "KR"
cert_state: "Seoul"
cert_location: "Gangnam"
cert_org: "Weka"
cert_org_unit: "Weka GSS"
cert_email_address: "rokmc756@gmail.com"

$ vi roles/ceph/vars/main.yml
cephadm:
  major_version: 18
  minor_version: 2
  patch_version: 0
  bin: "/root/cephadm"

server_url: "https://download.ceph.com/rpm-{{ cephadm.major_version }}.{{ cephadm.minor_version }}.{{ cephadm.patch_version }}/el9/noarch/cephadm"
download_cephadm: false
```

#### 4) Deploy Ceph Storage Cluster
```
$ vi install-hosts.yml
---
- hosts: all
  become: yes
  vars:
    print_debug: true
    install_cephadm: true
  roles:
    - { role: init-hosts }
    - { role: docker }
    - { role: ceph }

$ make install
```
#### 5) Destroy Ceph Storage Cluster
```
$ vi uninstall-hosts.yml
- hosts: all
  become: yes
  vars:
    print_debug: true
    uninstall_pkgs: true
  roles:
    - { role: ceph }
    - { role: docker }
    - { role: init-hosts }

$ make uninstall
```

## How to change admin password for Ceph Dashboard
```
$ cephadm shell
$ vi dashboard_password.yml
changeme
$ ceph dashboard ac-user-set-password admin -i ./dashboard_password.yml
```

## References
- https://kifarunix.com/how-to-deploy-ceph-storage-cluster-on-rocky-linux/?expand_article=1
- https://kifarunix.com/install-docker-on-rocky-linux/?expand_article=1
- https://www.flamingbytes.com/blog/how-to-uninstall-ceph-storage-cluster/
- https://gist.github.com/fmount/6203013d1c423dd831e3717b9986551b
