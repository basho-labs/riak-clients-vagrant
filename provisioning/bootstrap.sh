#!/bin/bash

printf '
######################################################################################
##                                                                                  ##
##                             Installing Ansible                                   ##
##                                                                                  ##
## While you wait, learn about Ansible: http://docs.ansible.com/                    ##
##                                                                                  ##
######################################################################################'

# install EPEL repo and allow deltarpms to save bandwidth
python -mplatform | grep -i centos && sudo yum -y install epel-release deltarpm

# install all updates except kernel updates (creates compatability problems with VBox Guest Additions)
python -mplatform | grep -iE 'Ubuntu|debian' && sudo apt-get update -y || sudo yum -y -x 'kernel*' update

python -mplatform | grep -iE 'Ubuntu|debian' && sudo apt-get install -y software-properties-common python-software-properties python-minimal aptitude libffi-dev python-pip python-dev git || sudo yum install -y git python-pip python-devel libffi-devel gcc openssl-devel

sudo pip install markupsafe

# install ansible
sudo pip install ansible

# install galaxy roles
sudo ansible-galaxy install -r /vagrant/provisioning/requirements.yml
sudo ansible-galaxy install -r /etc/ansible/roles/basho-labs/requirements.yml

# setup the local machine as the ansible host
echo 'riak-test' | sudo tee -a /etc/ansible/hosts

printf '
######################################################################################
##                                                                                  ##
##             Executing Ansible playbook, please be patient...                     ##
##                                                                                  ##
######################################################################################'

if [[ "$1" == *"kv"* ]]
then
	printf 'Running KV tests'
    ansible-playbook /vagrant/provisioning/playbook.yml
fi

if [[ "$1" == *"ts"* ]]
then
	printf 'Running TS tests'
    ansible-playbook /vagrant/provisioning/timeseries.yml
fi

if [[ "$1" == *"security"* ]]
then
	printf 'Running Security tests'
    ansible-playbook /vagrant/provisioning/security.yml
fi

printf '
######################################################################################
##                                                                                  ##
##                          Provisioning complete!                                  ##
##                                                                                  ##
## If you need to run the main playbook manually, use:                              ##
##   `sudo ansible-playbook /vagrant/provisioning/playbook.yml`                     ##
##                                                                                  ##
## Useful commands:                                                                 ##
##   - `vagrant ssh` login to your VM via ssh                                       ##
##   - `vagrant provision` rerun this provisioner                                   ##
##                                                                                  ##
## If you see red (error) above:                                                    ##
##   - Try vagrant destroy, then vagrant up again                                   ##
##   - If you cannot resolve it, please copy / pasta the error to a GitHub Issue    ##
##                                                                                  ##
######################################################################################
'
