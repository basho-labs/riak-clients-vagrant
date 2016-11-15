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

python -mplatform | grep -iE 'Ubuntu|debian' && sudo apt-get install -y software-properties-common python-software-properties python-minimal aptitude libffi-dev python-pip python-dev git || sudo yum install -y git

sudo pip install markupsafe

# install ansible
sudo pip install ansible

# setup the local machine as the ansible host
#echo 'riak-test' | sudo tee -a /etc/ansible/hosts

# install galaxy roles
sudo ansible-galaxy install -r /vagrant/provisioning/requirements.yml

printf '
######################################################################################
##                                                                                  ##
##             Executing Ansible playbook, please be patient...                     ##
##                                                                                  ##
######################################################################################'

if [ "$1" = "true" ]
then
    ansible-playbook -v /vagrant/provisioning/playbook.yml
fi

printf '
######################################################################################
##                                                                                  ##
##                          Provisioning complete!                                  ##
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
