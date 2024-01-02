
## How to change admin password for Ceph Dashboard
$ cephadm shell
$ vi dashboard_password.yml
changeme
$ ceph dashboard ac-user-set-password admin -i ./dashboard_password.yml


## References
https://kifarunix.com/how-to-deploy-ceph-storage-cluster-on-rocky-linux/?expand_article=1
https://kifarunix.com/install-docker-on-rocky-linux/?expand_article=1
