riak-clients-vagrant
====================

This is a vagrant package that simplifies the process of creating a VirtualBox virtual machine for development and testing of the supported Riak client libraries. To reduce dependencies on the host machine, it installs ansible onto the guest VM and then kicks off an Ansible playbook that uses a series of roles to provision Riak, as well as the environments needed for testing the client libraries on various versions of their respective programming languages. This package also makes use of the Ansible Galaxy Riak role, allowing us to ensure that it is working properly and make it easier to continue its development.

The package uses the VagrantBox from Chef running CentOS 7.2.

Currently supported client language environments with this package:
- PHP 5.5
- Ruby 1.9.3, 2.0.0, 2.1.6
- Python 2.6.7, 2.7.8, 3.3.6, 3.4.2

Under development language environments:
- Java
- NodeJS
- Multi-version support for PHP

Installation:
- Install vagrant and virtualbox
- Install vagrant vbguest plugin:  `vagrant plugin install vagrant-vbguest`
- From the root directory, run `cp Vagrantfile.template Vagrantfile && cp provisioning/playbook.yml.template provisioning/playbook.yml`
- Open Vagrantfile in your favorite editor and review/edit the settings for your guest VM as needed.
- Open provisioning/playbook.yml in your favorite editor and review/edit the settings for your guest VM as needed.
- Run `vagrant up`.

Troubleshooting:
- If any errors occur during initial boot, `vagrant up`, try running `vagrant ssh -c 'sudo yum -y update'`, then `vagrant reload`, and finally `vagrant provision`.
