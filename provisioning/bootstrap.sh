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
python -mplatform | grep -i '/Ubuntu|debian/' && sudo apt-get update -y || sudo yum -y -x 'kernel*' update

python -mplatform | grep -i '/Ubuntu|debian/' && sudo apt-get install -y software-properties-common python-software-properties python-minimal aptitude libffi-dev

python -mplatform | grep -i debian && sudo apt-get install -y python-pip python-dev git

# install ansible
sudo pip install ansible

# setup the local machine as the ansible host
echo 'riak-test' | sudo tee -a /etc/ansible/hosts

# setup ansible to look in our roles repo for roles
sudo sed -i -s 's/^\#roles_path    \= \/etc\/ansible\/roles/roles_path = \/etc\/ansible\/roles:\/vagrant\/ansible-roles/' /etc/ansible/ansible.cfg

# install galaxy roles
sudo ansible-galaxy install -r /vagrant/ansible-roles/requirements.txt

printf '
######################################################################################
##                                                                                  ##
##             Executing Ansible playbook, please be patient...                     ##
##                                                                                  ##
######################################################################################'

if [ "$1" = "true" ]
then
    ansible-playbook /vagrant/provisioning/playbook.yml
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
