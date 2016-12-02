#!/bin/bash

# Setup variables
# Which flavor or Riak to test, kv or ts
tests="kv"

# List of vagrant boxes to use
declare -a vmboxes=(
            "vagrant boxes"
          ) 
# List of riak package urls
# Note: the position of the packages for a specific OS in this array should
# correspond to the position of vagrant box in the previous array based on OS
declare -a riakpackages=(
              "url to riak packages"
              ) 
# Your Github personal access token
githubtoken="your github token"

export SMOKE_TESTS=$tests
numboxes=${#vmboxes[@]}
mkdir parallel

for (( i=1; i<${numboxes}+1; i++ ));
do
  	# Clone riak-clients-vagrant for each OS
	rsync -av --exclude='parallel' ./ ./parallel/vm$i
	cp ./parallel/vm$i/Vagrantfile.template ./parallel/vm$i/Vagrantfile && cp ./parallel/vm$i/provisioning/playbook.yml.template ./parallel/vm$i/provisioning/playbook.yml
	(cd ./parallel/vm$i/ && git submodule init && git submodule update)

	# Modify Vagrantfile v.name
	vname="vagrant-riak-clients-$i"
	sed -i ".bak" "s~vagrant-riak-clients~$vname~" ./parallel/vm$i/Vagrantfile

	# Set OS in Vagrantfile
	sed -i ".bak" "s~bento/centos-7.2~${vmboxes[$i-1]}~" ./parallel/vm$i/Vagrantfile

	if [[ "$tests" == *"kv"* ]]
	then
		printf 'Setting up KV playbook\n'
		playbook="playbook.yml"
	fi 
	
	if [[ "$tests" == *"ts"* ]]
	then
		printf 'Setting up TS playbook\n'
		playbook="timeseries.yml"
	fi
	# Configure playbook variables
	package="${riakpackages[$i-1]}"
	sed -i ".bak" "s~a_valid_package~'$package'~" ./parallel/vm$i/provisioning/$playbook
	sed -i ".bak" "s~a_valid_token~'$githubtoken'~" ./parallel/vm$i/provisioning/$playbook
	# Uncomment playbook lines
	sed -i ".bak" "s~#riak_testing_role_dev:~riak_testing_role_dev:~" ./parallel/vm$i/provisioning/$playbook
	sed -i ".bak" "s~#ct_github_token:~ct_github_token:~" ./parallel/vm$i/provisioning/$playbook
	sed -i ".bak" "s~#riak_package:~riak_package:~" ./parallel/vm$i/provisioning/$playbook
	sed -i ".bak" "s~#ct_test_libs:~ct_test_libs:~" ./parallel/vm$i/provisioning/$playbook
done

printf 'Running Tests...this could take awhile.\n'
for (( i=1; i<${numboxes}+1; i++ ));
do
	if (( ${numboxes} == 1 ))
	then
		VAGRANT_CWD=./parallel/vm$i/ vagrant up &
	else
		VAGRANT_CWD=./parallel/vm$i/ vagrant up >./parallel/vm$i/log$i.txt 2>&1 &
	fi
done
wait
printf 'Tests Complete\n'
printf "The VM's are still running\n"
printf "Some useful commands:\n"
for (( i=1; i<${numboxes}+1; i++ ));
do
	printf "VAGRANT_CWD=./parallel/vm$i/ vagrant ssh\n"
	printf "VAGRANT_CWD=./parallel/vm$i/ vagrant destroy\n"
	printf "cat ./parallel/vm$i/log$i.txt\n"
done
export SMOKE_TESTS=''