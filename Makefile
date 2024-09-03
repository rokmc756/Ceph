# add the IP address, username and hostname of the target hosts here
USERNAME=jomoon
COMMON="yes"
ANSIBLE_HOST_PASS="changeme"
ANSIBLE_TARGET_PASS="changeme"
ANSIBLE_PLAYBOOK_CMD="ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts'"

# include ./*.mk

GPHOSTS := $(shell grep -i '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' ./ansible-hosts | sed -e "s/ ansible_ssh_host=/,/g")

all:
	@echo ""
	@echo "[ Available targets ]"
	@echo ""
	@echo "init:            will install basic requirements (will ask several times for a password)"
	@echo "install:         will install the host with what is defined in install.yml"
	@echo "update:          run OS updates"
	@echo "ssh:             jump ssh to host"
	@echo "role-update:     update all downloades roles"
	@echo "available-roles: list known roles which can be downloaded"
	@echo "clean:           delete all temporary files"
	@echo ""
	@for GPHOST in ${GPHOSTS}; do \
		IP=$${GPHOST#*,}; \
		HOSTNAME=$${LINE%,*}; \
		echo "Current used hostname: $${HOSTNAME}"; \
		echo "Current used IP: $${IP}"; \
		echo "Current used user: ${USERNAME}"; \
		echo ""; \
	done

#init:	setup-hosts.yml update-hosts.yml
#	# $(shell sed -i -e '2s/.*/ansible_become_pass: ${ANSIBLE_TARGET_PASS}/g' ./group_vars/all.yml)
#	@echo ""
#	@for GPHOST in ${GPHOSTS}; do \
#		IP=$${GPHOST#*,}; \
#	    	HOSTNAME=$${LINE%,*}; \
#		echo "It will init host $${IP} and install ssh key and basic packages"; \
#		echo ""; \
#		echo "Note: NEVER use this step to init a host in an untrusted network!"; \
#		echo "Note: this will OVERWRITE any existing keys on the host!"; \
#		echo ""; \
#		echo "3 seconds to abort ..."; \
#		echo ""; \
#		sleep 3; \
#		echo "IP : $${IP} , HOSTNAME : $${HOSTNAME} , USERNAME : ${USERNAME}"; \
#		./init_host.sh "$${IP}" "${USERNAME}"; \
#	done
#	ansible-playbook -i ansible-hosts -u ${USERNAME} --ssh-common-args='-o UserKnownHostsFile=./known_hosts -o VerifyHostKeyDNS=true' install-ansible-prereqs.yml


# https://ansible-tutorial.schoolofdevops.com/control_structures/
download: role-update download-ceph.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} download-ceph.yml --tags="download"
init: role-update init-hosts.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} init-hosts.yml --tags="init"
uninit: role-update init-hosts.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} init-hosts.yml --tags="uninit"
boot: role-update control-vms.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} control-vms.yml --extra-vars "power_state=powered-on power_title=Power-On VMs"
shutdown: role-update control-vms.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} control-vms.yml --extra-vars "power_state=shutdown-guest power_title=Shutdown VMs"


ceph:
	@if [ "${r}" = "upload" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-ceph.yml -e '{upload_cephadm: True}' --tags='upload';\
	elif [ "${r}" = "install" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-ceph.yml -e '{install_ceph: True}' --tags='install';\
	elif [ "${r}" = "uninstall" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-ceph.yml -e '{uninstall_ceph: True}' --tags='uninstall';\
	elif [ "${r}" = "init" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-ceph.yml -e '{init_ceph: True}' --tags='init';\
	elif [ "${r}" = "purge" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-ceph.yml -e '{purge_ceph: True}' --tags='purge';\
	elif [ "${r}" = "add-ceph" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-ceph.yml -e '{add_ceph_nodes: True}' --tags='add-ceph';\
	elif [ "${r}" = "remove-ceph" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-ceph.yml -e '{remove_ceph_nodes: True}' --tags='remove-ceph';\
	elif [ "${r}" = "add-osd" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-ceph.yml -e '{add_osd_nodes: True}' --tags='add-osd';\
	elif [ "${r}" = "remove-osd" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-ceph.yml -e '{remove_osd_nodes: True}' --tags='remove-osd';\
	elif [ "${r}" = "uninstall" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} uninstall.yml --tags='uninstall';\
	else\
		echo "No Actions for Ceph";\
		exit;\
	fi



cephfs:
	@if [ "${r}" = "install" ]; then\
		if [ ! -z ${c} ] && [ "${c}" = "enable" ]; then\
			ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-cephfs.yml -e '{enable_cephfs: True}' -e '{enable_cephfs_client: True}' --tags='install';\
		elif [ ! -z ${c} ] && [ "${c}" != "enable" ]; then\
			echo "No Actions for Installing CephFS with Client";\
		else\
			ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-cephfs.yml -e '{enable_cephfs: True}' --tags='install';\
		fi;\
	elif [ "${r}" = "uninstall" ]; then\
		if [ ! -z ${c} ] && [ "${c}" = "enable" ]; then\
			ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-cephfs.yml -e '{enable_cephfs: True}' -e '{enable_cephfs_client: True}' --tags='uninstall';\
		elif [ ! -z ${c} ] && [ "${c}" != "enable" ]; then\
			echo "No Actions for Uninstalling CephFS with Client";\
		else\
			ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-cephfs.yml -e '{enable_cephfs: True}' --tags='uninstall';\
		fi;\
	elif [ -z ${r} ] && [ "${c}" = "enable" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-cephfs.yml -e '{enable_cephfs_client: True}' --tags='install';\
	elif [ -z ${r} ] && [ "${c}" = "disable" ]; then\
		ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-cephfs.yml -e '{enable_cephfs_client: True}' --tags='uninstall';\
	else\
		echo "No Actions for CephFS";\
		exit;\
	fi


block:
	@if [ "${r}" = "install" ]; then\
		if [ ! -z ${r} ] && [ "${s}" = "rbd" ]; then\
			ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-block.yml -e '{enable_rbd: True}' --tags='install';\
		elif [ ! -z ${r} ] && [ "${s}" = "iscsi" ]; then\
			ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-block.yml -e '{enable_iscsi: True}' --tags='install';\
		else\
			echo "No Actions for Installing Block";\
		fi;\
	elif [ "${r}" = "uninstall" ]; then\
		if [ ! -z ${r} ] && [ "${s}" = "rbd" ]; then\
			ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-block.yml -e '{enable_rbd: True}' --tags='uninstall';\
		elif [ ! -z ${r} ] && [ "${s}" = "iscsi" ]; then\
			ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-block.yml -e '{enable_iscsi: True}' --tags='uninstall';\
		else\
			echo "No Actions for Uninstalling Block";\
		fi;\
	else\
		echo "No Actions for Block";\
		exit;\
	fi


rgw:
	@if [ "${r}" = "install" ]; then\
		if [ ! -z ${r} ] && [ "${s}" = "single" ]; then\
			if [ -z ${c} ];  then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{enable_single_rgw: True}' --tags='install';\
			elif [ ! -z ${c} ] && [ "${c}" = "enable" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{enable_single_rgw: True}' -e '{enable_single_client: True }' --tags='install';\
			elif [ ! -z ${c} ] && [ "${c}" = "only" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{enable_single_client: True }' --tags='install';\
			else\
				echo "No Actions for Installing Single Rados Gateway with Client";\
			fi\
		elif [ ! -z ${r} ] && [ "${s}" = "multi" ]; then\
			if [ -z ${c} ];  then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{enable_multi_rgw: True}' --tags='install';\
			elif [ ! -z ${c} ] && [ "${c}" = "enable" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{enable_multi_rgw: True}' -e '{enable_multi_client: True}' --tags='install';\
			elif [ ! -z ${c} ] && [ "${c}" = "only" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{enable_multi_client: True}' --tags='install';\
			else\
				echo "No Actions for Installing Multi Rados Gateway with Client";\
			fi\
		else\
			echo "No Actions for Installing Rados Gateway";\
		fi;\
	elif [ "${r}" = "uninstall" ]; then\
		if [ ! -z ${r} ] && [ "${s}" = "single" ]; then\
			if [ -z ${c} ];  then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{disable_single_rgw: True}' --tags='uninstall';\
			elif [ ! -z ${c} ] && [ "${c}" = "disable" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{disable_single_rgw: True}' -e '{disable_single_client: True}' --tags='uninstall';\
			elif [ ! -z ${c} ] && [ "${c}" = "only" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{disable_single_client: True}' --tags='uninstall';\
			else\
				echo "No Actions for Uninstalling Multi Rados Gateway with Client";\
			fi\
		elif [ ! -z ${r} ] && [ "${s}" = "multi" ]; then\
			if [ -z ${c} ];  then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{disable_multi_rgw: True}' --tags='uninstall';\
			elif [ ! -z ${c} ] && [ "${c}" = "disable" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{disable_multi_rgw: True}' -e '{disable_multi_client: True}' --tags='uninstall';\
			elif [ ! -z ${c} ] && [ "${c}" = "only" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-radosgw.yml -e '{disable_multi_client: True}' --tags='uninstall';\
			else\
				echo "No Actions for Uninstalling Multi Rados Gateway with Client";\
			fi\
		else\
			echo "No Actions for Uninstalling Rados Gateway";\
		fi;\
	else\
		echo "No Actions for Rados Gateway";\
		exit;\
	fi



nfs:
	@if [ "${r}" = "install" ]; then\
		if [ ! -z ${r} ] && [ "${s}" = "single" ]; then\
			if [ -z ${c} ];  then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{enable_single_nfs: True}' --tags='install';\
			elif [ ! -z ${c} ] && [ "${c}" = "enable" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{enable_single_nfs: True}' -e '{enable_single_client: True }' --tags='install';\
			elif [ ! -z ${c} ] && [ "${c}" = "only" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{enable_single_client: True }' --tags='install';\
			else\
				echo "No Actions for Installing Single NFS with Clients";\
			fi\
		elif [ ! -z ${r} ] && [ "${s}" = "ganesha" ]; then\
			if [ -z ${c} ];  then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{enable_nfs_ganesha: True}' --tags='install';\
			elif [ ! -z ${c} ] && [ "${c}" = "enable" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{enable_nfs_ganesha: True}' -e '{enable_multi_client: True}' --tags='install';\
			elif [ ! -z ${c} ] && [ "${c}" = "only" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{enable_multi_client: True}' --tags='install';\
			else\
				echo "No Actions for Installing NFS Ganesha with Clients";\
			fi\
		else\
			echo "No Actions for Installing NFS";\
		fi;\
	elif [ "${r}" = "uninstall" ]; then\
		if [ ! -z ${r} ] && [ "${s}" = "single" ]; then\
			if [ -z ${c} ];  then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{disable_single_nfs: True}' --tags='uninstall';\
			elif [ ! -z ${c} ] && [ "${c}" = "disable" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{disable_single_nfs: True}' -e '{disable_single_client: True}' --tags='uninstall';\
			elif [ ! -z ${c} ] && [ "${c}" = "only" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{disable_single_client: True}' --tags='uninstall';\
			else\
				echo "No Actions for Uninstalling Single NFS with Clients";\
			fi\
		elif [ ! -z ${r} ] && [ "${s}" = "ganesha" ]; then\
			if [ -z ${c} ];  then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{disable_nfs_ganesha: True}' --tags='uninstall';\
			elif [ ! -z ${c} ] && [ "${c}" = "disable" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{disable_nfs_ganesha: True}' -e '{disable_multi_client: True}' --tags='uninstall';\
			elif [ ! -z ${c} ] && [ "${c}" = "only" ]; then\
				ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} config-nfs.yml -e '{disable_multi_client: True}' --tags='uninstall';\
			else\
				echo "No Actions for Uninstalling NFS Ganesha With Clients";\
			fi\
		else\
			echo "No Actions for Uninstalling NFS";\
		fi;\
	else\
		echo "No Actions for Installing or Uninstalling NFS";\
		exit;\
	fi





#install: role-update install.yml
#	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -i ansible-hosts -u ${USERNAME} install.yml --tags="install"

#uninstall: role-update uninstall.yml
#	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -i ansible-hosts -u ${USERNAME} uninstall.yml --tags="uninstall"

#upgrade: role-update upgrade-hosts.yml
#	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -i ansible-hosts -u ${USERNAME} upgrade-hosts.yml --tags="upgrade"

update:
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -i ${IP}, -u ${USERNAME} update-hosts.yml

# https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
no_targets__:
role-update:
	sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep '^ansible-update-*'" | xargs -n 1 make --no-print-directory
        $(shell sed -i -e '2s/.*/ansible_become_pass: ${ANSIBLE_HOST_PASS}/g' ./group_vars/all.yml )

ssh:
	ssh -o UserKnownHostsFile=./known_hosts ${USERNAME}@${IP}

install.yml:
	cp -a install.template install.yml

update.yml:
	cp -a update-hosts.template update.yml

clean:
	rm -rf ./known_hosts install.yml update.yml

.PHONY:	all init install update ssh common clean no_targets__ role-update
