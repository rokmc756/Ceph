# gzip cephadm -S -.gz
# gunzip cephadm-.gz
# mv cephadm- minio

#
tar czfp cephadm-.tar.gz minio
tar xvzf cephadm-.tar.gz

# CEPH_RELEASE=18.2.0 # replace this with the active release
# curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm
