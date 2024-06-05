
## References
* https://docs.ceph.com/en/octopus/install/build-ceph/


## How to Build Ceph
* On Rocky 9.x
~~~

$ git clone https://github.com/ceph/ceph

$ cd ceph

$ ./install-deps.sh

$ ./do_cmake.sh

$ 

~~~


## Build RPMS
~~~
$ cd /root

$ dnf -y install rpm-build rpmdevtools

$ rpmdev-setuptree

$ wget -P ~/rpmbuild/SOURCES/ https://download.ceph.com/tarballs/ceph-18.2.1.tar.gz

$ tar --strip-components=1 -C ~/rpmbuild/SPECS/ --no-anchored -xvzf ~/rpmbuild/SOURCES/ceph-18.2.1.tar.gz "ceph.spec"

$ rpmbuild -ba ~/rpmbuild/SPECS/ceph.spec
warning: line 1101: It's not recommended to have unversioned Obsoletes: Obsoletes:      ceph-libcephfs
error: Bad source: /root/rpmbuild/SOURCES/ceph-18.2.1.tar.bz2: No such file or directory

$ vi ~/rpmbuild/SPECS/ceph.spec

$ rpmbuild -ba ~/rpmbuild/SPECS/ceph.spec
warning: line 1101: It's not recommended to have unversioned Obsoletes: Obsoletes:      ceph-libcephfs
error: Failed build dependencies:
        luarocks is needed by ceph-2:18.2.1-0.el9.x86_64

$ dnf -y install luarocks

$ rpmbuild -ba ~/rpmbuild/SPECS/ceph.spec
warning: line 1101: It's not recommended to have unversioned Obsoletes: Obsoletes:      ceph-libcephfs
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.1X9E6H
~~ snip

~~~

