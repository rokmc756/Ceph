Setup: Rados Gateway on Cluster 1
Cluster 1 will be our primary cluster. SSH in to ceph-mon01 VM.

Lets define some variables. You can provide your own variable names and use your own IPs and hostnames

# Variables CEPH-CLUSTER-1
export rgw_realm="pakistan"
export zonegroup_name="punjab"
export zone_name="lahore"
export endpoints="192.168.99.64"
export placement="3 ceph-mon01 ceph-mon02 ceph-mon03"
export replication_user="${zone_name}-ReplicationUser"
Create a realm

radosgw-admin realm create --rgw-realm=$rgw_realm --default
Create a zonegroup

radosgw-admin zonegroup create --rgw-zonegroup=$zonegroup_name --endpoints=$endpoints --master --default
Create a zone

radosgw-admin zone create --rgw-zonegroup=$zonegroup_name \
                          --rgw-zone=$zone_name \
                          --endpoints=$endpoints \
                          --master --default 
Commit changes

radosgw-admin period update --rgw-realm=$rgw_realm --commit
Create a replication user. Save ACCESS_KEY and SECRET_KEY values. These values will be needed when we configure rgw on second cluster.

radosgw-admin user create --uid=$replication_user --display-name=$replication_user --system > "${replication_user}-keys"

export ACCESS_KEY=$(grep -o '"access_key": "[^"]*' "${replication_user}-keys" | awk -F'"' '{print $4}')
export SECRET_KEY=$(grep -o '"secret_key": "[^"]*' "${replication_user}-keys" | awk -F'"' '{print $4}')



Update Zone keys with user keys we just created

radosgw-admin zone modify --rgw-zone=$zone_name --access-key=$ACCESS_KEY --secret=$SECRET_KEY
Commit the changes

radosgw-admin period update --commit
Deploy rgw

ceph orch apply rgw $zone_name --realm=$rgw_realm --zone=$zone_name --placement="$placement"
Verify rgw is deployed

# Should see 3 rgw services 
$ ceph orch ls

# S3 endpoint should be available 
$ curl -k http://localhost:80/
<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>anonymous</ID><DisplayName></DisplayName></Owner><Buckets></Buckets></ListAllMyBucketsResult>







Setup: Rados Gateway on Cluster 2
Cluster 2 will be our secondary cluster. SSH in to ceph-node01 VM.

Lets define some variables. Use the ACCESS_KEY and SECRET_KEY values from cluster 1.

# Variables CEPH-CLUSTER-2
export rgw_realm="pakistan"
export zonegroup_name="punjab"
export zone_name="pindi"
export endpoints="192.168.99.61"
export access_key="<ACCESS_KEY from cluster 1>" # notsecret
export secret_key="<SECRET_KEY from cluster 1>" # notsecret
export placement="3 ceph-node01 ceph-node02 ceph-node03"
export primarycluster="http://192.168.99.64:80"
Pull realm, zonegroup and zone from primary cluster

Create a local zone on secondary cluster

Deploy rgw

# Pull realm
radosgw-admin realm pull --rgw-realm=$rgw_realm --url=$primarycluster --access-key=$access_key --secret-key=$secret_key --default

# Let pull zonegroup and zone from primary ceph cluster
radosgw-admin period pull --url=$primarycluster --access-key=$access_key --secret-key=$secret_key 

# Lets create a local zone for this cluster
radosgw-admin zone create --rgw-zonegroup=$zonegroup_name \
             --rgw-zone=$zone_name --endpoints=$endpoints \
             --access-key=$access_key --secret=$secret_key 

# commit changes
radosgw-admin period update --commit

# Deploy rgw
ceph orch apply rgw $zone_name --realm=$rgw_realm --zone=$zone_name --placement="$placement"


