USERNAME=jomoon
COMMON="yes"
ANSIBLE_HOST_PASS="changeme"
ANSIBLE_TARGET_PASS="changeme"


# Control VMs in KVM For Power On or Off
boot:
	@ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} control-vms.yml --extra-vars "power_state=powered-on power_title=Power-On VMs"

shutdown:
	@ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} control-vms.yml --extra-vars "power_state=shutdown-guest power_title=Shutdown VMs"

# For All Roles
%:
	@cat Makefile.tmp  | sed -e 's/temp/${*}/g' > Makefile.${*}
	@cat setup-temp.yml.tmp | sed -e 's/    - temp/    - ${*}/g' > setup-${*}.yml
	@make -f Makefile.${*} r=${r} s=${s} c=${c} USERNAME=${USERNAME}
	@rm -f setup-${*}.yml Makefile.${*}


#	@make -f ./configs/Makefile.${*} r=${r} s=${s} c=${c} USERNAME=${USERNAME}

# clean:
# 	rm -rf ./known_hosts install-hosts.yml update-hosts.yml


# https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
#no_targets__:
#role-update:
#	sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep '^ansible-update-*'" | xargs -n 1 make --no-print-directory
#        $(shell sed -i -e '2s/.*/ansible_become_pass: ${ANSIBLE_HOST_PASS}/g' ./group_vars/all.yml )


# Need to check what it should be needed
.PHONY:	all init install update ssh common clean no_targets__ role-update

