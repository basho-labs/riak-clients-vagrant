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
python -mplatform | grep -i Ubuntu && sudo apt-get install -y software-properties-common python-software-properties
python -mplatform | grep -i Ubuntu && sudo add-apt-repository -y ppa:ansible/ansible || sudo yum -y install epel-release deltarpm

# install all updates except kernel updates (creates compatability problems with VBox Guest Additions)
python -mplatform | grep -i Ubuntu && sudo apt-get update -y || sudo yum -y -x 'kernel*' update

# install ansible
python -mplatform | grep -i Ubuntu && sudo apt-get install -y ansible || sudo yum -y install ansible

# setup the local machine as the ansible host
echo 'riak-test' | sudo tee -a /etc/ansible/hosts

# setup ansible to look in our roles repo for roles
sudo sed -i -s 's/^\#roles_path    \= \/etc\/ansible\/roles/roles_path = \/etc\/ansible\/roles:\/vagrant\/ansible-roles/' /etc/ansible/ansible.cfg

# install galaxy roles
sudo ansible-galaxy install basho-labs.riak-kv geerlingguy.php geerlingguy.composer joshualund.golang geerlingguy.java geerlingguy.repo-remi geerlingguy.nodejs geerlingguy.ruby --ignore-errors

printf '
######################################################################################
##                                                                                  ##
##             Executing Ansible playbook, please be patient...                     ##
##                                                                                  ##
######################################################################################'

#ansible-playbook /vagrant/provisioning/playbook.yml

printf '
######################################################################################
##                                                                                  ##
##                          Provisioning complete!                                  ##
##                                                                                  ##
## If you see red (error) above:                                                    ##
##   - Try vagrant destroy, then vagrant up again                                   ##
##   - Copy and paste the error to https://gist.github.com/, then send me the link  ##
##                                                                                  ##
######################################################################################
'
