#!/bin/bash

# Setup variables
# Which flavor or Riak to test, kv or ts

# List of vagrant boxes to use
declare -a vmboxes=(
            "put vagrant boxes here"
            "put vagrant boxes here"
            "put vagrant boxes here"
          ) 
# List of riak package urls
# Note: the position of the packages for a specific OS in this array should
# correspond to the position of vagrant box in the previous array based on OS
declare -a riakpackages=(
              "put package urls here"
              "put package urls here"
              "put package urls here"
              ) 

numboxes=${#vmboxes[@]}
mkdir parallel

printf 'Running Tests...this could take awhile.\n'
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

	if [[ "$SMOKE_TESTS" == *"kv"* ]]
	then
		printf 'Setting up KV playbook\n'
		playbook="playbook.yml"
	fi 
	
	if [[ "$SMOKE_TESTS" == *"ts"* ]]
	then
		printf 'Setting up TS playbook\n'
		playbook="timeseries.yml"
	fi
	# Configure playbook variables
	package="${riakpackages[$i-1]}"
	export EXTRA_VARS="{'riak_package': '$package', 'ct_github_token': '$CT_GITHUB_TOKEN', 'ct_test_libs': $CT_TEST_LIBS, 'riak_testing_role_dev': '$RIAK_TESTING_ROLE_DEV'}"

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