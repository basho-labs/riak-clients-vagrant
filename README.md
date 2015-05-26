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
- If any errors occur during initial boot, `vagrant up`, try running `vagrant ssh -c 'sudo yum -y update'`, then `vagrant reload`, and finally `vagrant provision`.