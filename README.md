riak-clients-vagrant
====================

Vagrant package for executing unit &amp; integration tests as well as code coverage reports.


Installation:
- Install vagrant and virtualbox
- Install vagrant vbguest plugin:  `vagrant plugin install vagrant-vbguest`
- From the root directory, run `cp Vagrantfile.template Vagrantfile && cp provisioning/playbook.yml.template provisioning/playbook.yml`
- Open Vagrantfile in your favorite editor and review/edit the settings for your guest VM as needed.
- Open provisioning/playbook.yml in your favorite editor and review/edit the settings for your guest VM as needed.
- Run `vagrant up`.

Troubleshooting:
- If during initial boot (vagrant up), it complains about not being able to update virtualbox-extensions on the vm, ssh into the vm using `vagrant ssh` and then update the vm's packages and kernel with command 'sudo yum update -y'. Then `exit` your ssh session and run `vagrant reload` to reload the guest with the file shares.
