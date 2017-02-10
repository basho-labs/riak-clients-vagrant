riak-clients-vagrant
====================

This is a vagrant package that simplifies the process of creating a VirtualBox virtual machine for development and testing of the supported Riak client libraries. To reduce dependencies on the host machine, it installs ansible onto the guest VM and then kicks off an Ansible playbook that uses a series of roles to provision Riak, as well as the environments needed for testing the client libraries on various versions of their respective programming languages. This package also makes use of the Ansible Galaxy Riak role, allowing us to ensure that it is working properly and make it easier to continue its development.

The package uses the Vagrant Boxes from Chef (bento) running CentOS 7.2 and Ubuntu 16.04.

# Status & Roadmap

Currently supported client language environments with this package:

- PHP
- Go
- Ruby
- Java
- NodeJS

Under development or on the roadmap for development:

- PHP PB
- Python
- Erlang
- .NET Mono
- .NET on Windows
- .NET Core

# Installation

- Install vagrant and virtualbox
- Clone this repository to your host machine
- From the project root directory, run `cp Vagrantfile.template Vagrantfile && cp provisioning/playbook.yml.template provisioning/playbook.yml`
- Open Vagrantfile in your favorite editor and review/edit the settings for your guest VM as needed (e.g. path to file system shares between the host and guest machines)
- Open provisioning/playbook.yml in your favorite editor and review/edit the settings for your guest VM as needed
- Next initialize and update the git submodules by running `git submodule init && git submodule update`, which will fetch the ansible-roles and client tools repositories
- Export variable SMOKE_TESTS. This variable should be set to `kv` or `ts`. `export SMOKE_TESTS="kv"` or `export SMOKE_TESTS="ts"`. If not exported, defaults to `kv`
- Run `vagrant up` to turn on your VM for the first time. It will automatically do the initial provisioning for the guest machine
- After the machine has completed initial provisioning, login to it by running `vagrant ssh`
- Once in the machine, run `ansible-playbook /vagrant/provisioning/playbook.yml` to install Riak (alternatively you can run timeseries.yml or security.yml to test TS or security instead)
- After you are done with the machine, you can type `exit` to exit the ssh shell and then `vagrant suspend` to suspend the state of the guest machine for use next time
- If you are completely done with the guest machine, you can run `vagrant destroy` which will destroy the virtual disks and require you to rerun the provisioners to use it again

# Ansible Galaxy Riak role development

If you want to contribute to the Ansible Riak role, clone the repository to `provisioning/roles/basho-labs.riak-kv.dev` and `riak_testing_role_dev: true` to your playbook.yml. This will tell signal to the Ansible roles to use the local checkout for playbook execution instead of the latest release to Ansible Galaxy.

# Running tests in parallel with `multi-test.sh`
- Open `multi-test.sh` and add your target vagrant boxes and Riak package URLs in the appropriate place
- `export CT_GITHUB_TOKEN="put your github token here"`
- `export SMOKE_TESTS="ts"` or `export SMOKE_TESTS="kv"`. If not exported, defaults to `kv`
- `export CT_TEST_LIBS="['php', 'go', 'ruby', 'nodejs', 'java']"`
- `export RIAK_TESTING_ROLE_DEV="true"` to set the Ansible variable `riak_testing_role_dev` mentioned above
- Set concurrency limit, e.g. `export CONCURRENCY_LIMIT=1` for sequential runs or `export CONCURRENCY_LIMIT=3` for 3 VM's at a time
- `sh multi-test.sh run`
- After running the tests, you can clean up with `sh multi-test.sh cleanup`. This will shutdown all VMs and delete their directories. This will leave the test results in `./results`
- Run `sh multi-test.sh reset` to delete all VM's and testing directories, including the `./results`
