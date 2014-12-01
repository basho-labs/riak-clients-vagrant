riak-clients-vagrant
====================

Vagrant package for executing unit &amp; integration tests as well as code coverage reports.


Troubleshooting:

- if you have troubles with mounting shared drives between host and guest, try installing the vbguest plugin then vagrant reload (https://github.com/mitchellh/vagrant/issues/3341)
	`vagrant plugin install vagrant-vbguest`
