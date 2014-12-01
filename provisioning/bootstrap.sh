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
sudo ansible-galaxy install basho.riak

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
######################################################################################'

# install git, vim, ruby, riak and dependencies
sudo yum -y install gcc gcc-c++ glibc-devel make git pam-devel ruby ruby-devel vim riak expect

# install ruby bundler
gem install bundler

# dl & install java7
sudo rpm -Uvh https://www.dropbox.com/s/nfacffgd2cj1bli/jdk-7u72-linux-x64.rpm?dl=1

# setup Riak config
sudo echo 'search = on' >> /etc/riak/riak.conf
sudo echo 'storage_backend = leveldb' >> /etc/riak/riak.conf
sudo echo 'listener.http.internal = 0.0.0.0:8098' >> /etc/riak/riak.conf
sudo echo 'listener.protobuf.internal = 0.0.0.0:8087' >> /etc/riak/riak.conf
sudo echo 'ssl.certfile = /vagrant/certs/server.crt' >> /etc/riak/riak.conf
sudo echo 'ssl.keyfile = /vagrant/certs/server.key' >> /etc/riak/riak.conf
sudo echo 'ssl.cacertfile = /vagrant/certs/ca.crt' >> /etc/riak/riak.conf
sudo echo 'buckets.default.allow_mult = true' >> /etc/riak/riak.conf
sudo echo 'tls_protocols.tlsv1.1 = on' >> /etc/riak/riak.conf
sudo echo 'check_crl = off' >> /etc/riak/riak.conf

# setup ulimit
sudo touch /etc/security/limits.conf
sudo echo 'root                hard    nofile  65536' >> /etc/security/limits.conf
sudo echo 'root                soft    nofile  65536' >> /etc/security/limits.conf

# start riak
sudo riak start

# setup riak buckets
sudo riak-admin bucket-type create counters '{"props":{"datatype":"counter", "allow_mult":true}}'
sudo riak-admin bucket-type create other_counters '{"props":{"datatype":"counter", "allow_mult":true}}'
sudo riak-admin bucket-type create maps '{"props":{"datatype":"map", "allow_mult":true}}'
sudo riak-admin bucket-type create sets '{"props":{"datatype":"set", "allow_mult":true}}'
sudo riak-admin bucket-type create yokozuna '{"props":{}}'

sudo riak-admin security add-user user password=password
sudo riak-admin security add-user certuser

sudo riak-admin security add-source user 0.0.0.0/0 password
sudo riak-admin security add-source certuser 0.0.0.0/0 certificate

sudo riak-admin security grant riak_kv.get,riak_kv.put,riak_kv.delete,riak_kv.index,riak_kv.list_keys,riak_kv.list_buckets,riak_core.get_bucket,riak_core.set_bucket,riak_core.get_bucket_type,riak_core.set_bucket_type,search.admin,search.query,riak_kv.mapreduce on any to user

# wait for bucket types to settle
sudo sleep 10

sudo riak-admin bucket-type activate other_counters
sudo riak-admin bucket-type activate counters
sudo riak-admin bucket-type activate maps
sudo riak-admin bucket-type activate sets
sudo riak-admin bucket-type activate yokozuna

sudo riak ping