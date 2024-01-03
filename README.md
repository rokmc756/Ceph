## The Ceph Storage Cluster Architecture
![alt text](https://github.com/rokmc756/Ceph/blob/main/roles/ceph/files/ceph_architecture.webp)

## The Archiecture example to deploy Ceph Storage Cluster
![alt text](https://github.com/rokmc756/Ceph/blob/main/roles/ceph/files/ceph_vm_architecture.png)


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

