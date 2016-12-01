#!/bin/bash

# Setup variables
tests="ts"
#githubtoken="put you github token here"
githubtoken="token"
declare -a vmboxes=(
						"vagrant box to use"
					) 

declare -a kvosspackages=(
							"url to riak kv package"
						  ) 

declare -a tsosspackages=(
							"url to riak ts package"
						  ) 

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
		# Set variables in playbook.yml
		printf 'Setting up KV playbook\n'
		package="${kvosspackages[$i-1]}"
		sed -i ".bak" "s~a_valid_package~'$package'~" ./parallel/vm$i/provisioning/playbook.yml
		sed -i ".bak" "s~a_valid_token~'$githubtoken'~" ./parallel/vm$i/provisioning/playbook.yml
		sed -i ".bak" "s~#riak_testing_role_dev:~riak_testing_role_dev:~" ./parallel/vm$i/provisioning/playbook.yml
		sed -i ".bak" "s~#ct_github_token:~ct_github_token:~" ./parallel/vm$i/provisioning/playbook.yml
		sed -i ".bak" "s~#riak_package:~riak_package:~" ./parallel/vm$i/provisioning/playbook.yml
		sed -i ".bak" "s~#ct_test_libs:~ct_test_libs:~" ./parallel/vm$i/provisioning/playbook.yml
		sed -i ".bak" "s~['php','go']~['$clients']~" ./parallel/vm$i/provisioning/playbook.yml
	fi 
	
	if [[ "$tests" == *"ts"* ]]
	then
		# Set variables in timeseries.yml
		printf 'Setting up TS playbook\n'
		package="${tsosspackages[$i-1]}"
		sed -i ".bak" "s~a_valid_package~'$package'~" ./parallel/vm$i/provisioning/timeseries.yml
		sed -i ".bak" "s~a_valid_token~'$githubtoken'~" ./parallel/vm$i/provisioning/timeseries.yml
		sed -i ".bak" "s~#riak_testing_role_dev:~riak_testing_role_dev:~" ./parallel/vm$i/provisioning/timeseries.yml
		sed -i ".bak" "s~#ct_github_token:~ct_github_token:~" ./parallel/vm$i/provisioning/timeseries.yml
		sed -i ".bak" "s~#riak_package:~riak_package:~" ./parallel/vm$i/provisioning/timeseries.yml
	fi
done

for (( i=1; i<${numboxes}+1; i++ ));
do
	printf 'Running Tests...this could take awhile.\n'
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
