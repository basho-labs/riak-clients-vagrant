#!/bin/bash

printf '
######################################################################################
##                                                                                  ##
##                             Installing Ansible                                   ##
##                                                                                  ##
## While you wait, learn about Ansible: http://docs.ansible.com/                    ##
##                                                                                  ##
######################################################################################'


# centos 6
wget https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

# centos 7
# wget https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm

# install EPEL repository and update
sudo yum -y install epel-release-*.noarch.rpm
sudo yum -y update

# install ansible
sudo yum -y install ansible

# setup the local machine as the host
sudo echo localhost > /etc/ansible/hosts

# install galaxy roles
sudo ansible-galaxy install basho.riak rvm_io.rvm1-ruby

printf '
######################################################################################
##                                                                                  ##
##             Executing Ansible playbook, please be patient...                     ##
##                                                                                  ##
######################################################################################'

sudo ansible-playbook /vagrant/provisioning/playbook.yml --connection=local

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
