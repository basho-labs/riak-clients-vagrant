#!/bin/bash

# Setup variables
# List of vagrant boxes to use
            #"bento/ubuntu-16.04"
            #"bento/debian-8.5"
            #"bento/centos-7.2"
            #"bento/ubuntu-14.04"
            #"bento/debian-7.8"
            #"bento/centos-6.7"
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

if [ -z ${CT_GITHUB_TOKEN+x} ]; then printf 'Variable CT_GITHUB_TOKEN not set. Exiting...' && exit; fi
if [ -z ${SMOKE_TESTS+x} ]; then printf 'Variable SMOKE_TESTS not set. Exiting...' && exit; fi
if [ -z ${CT_TEST_LIBS+x} ]; then printf 'Variable CT_TEST_LIBS not set. Exiting...' && exit; fi
if [ -z ${RIAK_TESTING_ROLE_DEV+x} ]; then printf 'Variable RIAK_TESTING_ROLE_DEV not set. Exiting...' && exit; fi
if [ -z ${CONCURRENCY_LIMIT+x} ]; then printf 'Variable CONCURRENCY_LIMIT not set. Exiting...' && exit; fi

numboxes=${#vmboxes[@]}
numpackages=${#riakpackages[@]}

if (( ${numboxes} == 0 )); then printf 'No VMs specified. Exiting...' && exit; fi
if (( ${numpackages} == 0 )); then printf 'No Riak packages specified. Exiting...' && exit; fi
if (( ${numpackages} != ${numboxes})); then printf 'There should be one VM declared for each Riak package. Exiting...' && exit; fi

if [[ "$1" == "run" ]]
then
    printf 'Running Tests...this could take a while.\n'
elif [[ "$1" == "cleanup" ]]
then
    for i in $(ls -d ./parallel/*/)
    do
        VAGRANT_CWD=${i} vagrant destroy --force &
    done
    wait

    rm -rf ./parallel
    exit
elif [[ "$1" == "reset" ]]
then
    for i in $(ls -d ./parallel/*/)
    do 
        VAGRANT_CWD=${i} vagrant destroy --force &
    done
    wait

    rm -rf ./parallel
    rm -rf results
    exit
else
    printf 'Aborting. No command selected.\n'
    printf 'Your options are: run, cleanup, reset.\n'
    exit
fi

mkdir parallel
mkdir results

for (( i=1; i<${numboxes}+1; i++ ));
do
    printf 'Clone riak-clients-vagrant repo for each target VM \n'
    rsync -av --exclude="parallel" --exclude=".*" --exclude ".*/" ./ ./parallel/vm${i} >/dev/null 2>&1
    cp ./parallel/vm${i}/Vagrantfile.template ./parallel/vm${i}/Vagrantfile && cp ./parallel/vm${i}/provisioning/playbook.yml.template ./parallel/vm${i}/provisioning/playbook.yml
    (cd ./parallel/vm${i}/ && git submodule init && git submodule update)

    printf 'Setting Vagrantfile v.name \n'
    vname="vagrant-riak-clients-$i"
    sed -i ".bak" "s~vagrant-riak-clients~vagrant-riak-clients-${i}~" ./parallel/vm${i}/Vagrantfile

    printf 'Setting Vagrantfile config.vm.box \n'
    sed -i ".bak" "s~bento/centos-7.2~${vmboxes[$i-1]}~" ./parallel/vm${i}/Vagrantfile

    if [[ "$SMOKE_TESTS" == "kv" ]]
    then
        printf 'Setting up KV playbook\n'
        playbook="playbook.yml"
    elif [[ "$SMOKE_TESTS" == "ts" ]]
    then
        printf 'Setting up TS playbook\n'
        playbook="timeseries.yml"
    else
        printf 'Unrecognized test suite selected...\n'
        printf 'Please export SMOKE_TESTS="kv" or export SMOKE_TESTS="ts" and re-run this script...\n'
        rm -rf parallel
        exit
    fi

    package="${riakpackages[$i-1]}"
    export EXTRA_VARS="{'riak_package': '$package', 'ct_github_token': '$CT_GITHUB_TOKEN', 'ct_test_libs': $CT_TEST_LIBS, 'riak_testing_role_dev': '$RIAK_TESTING_ROLE_DEV'}"
    printf "EXTRA_VARS='${EXTRA_VARS}' \n"
    if (( ${numboxes} == 1 ))
    then
        VAGRANT_CWD=./parallel/vm${i}/ vagrant up | tee ./parallel/vm${i}/log.txt &
    else
        VAGRANT_CWD=./parallel/vm${i}/ vagrant up >./parallel/vm${i}/log.txt 2>&1 &
    fi
    if (( ${i} % ${CONCURRENCY_LIMIT} == 0 )) || (( ${i}  == ${numboxes} ))
    then
        printf "Concurrency limit reached...waiting for this batch to complete before running next batch..."
        wait
        printf "Batch complete... \n"
        printf "Gathering test results... \n"

        for (( j=1+$(( $(( (${i} - 1) / ${CONCURRENCY_LIMIT} )) * ${CONCURRENCY_LIMIT})); j<${i}+1; j++ ));
        do
            printf "Grabbing logs from within VM${j}... \n"
            VAGRANT_CWD=./parallel/vm${j}/ vagrant ssh -- 'if [ -e /var/log/client_smoke_tests ]; then cp -R /var/log/client_smoke_tests /vagrant/test_logs; fi' &
        done
        wait

        for (( j=1+$(( $(( (${i} - 1) / ${CONCURRENCY_LIMIT} )) * ${CONCURRENCY_LIMIT})); j<${i}+1; j++ ));
        do
            printf "Suspending VM${j}... \n"
            VAGRANT_CWD=./parallel/vm${j}/ vagrant suspend &
        done
        wait

        for (( j=1+$(( $(( (${i} - 1) / ${CONCURRENCY_LIMIT} )) * ${CONCURRENCY_LIMIT})); j<${i}+1; j++ ));
        do
            box="${vmboxes[$j-1]}"
            prefixbox=${box////-}
            prefixbox=${prefixbox#"bento-"}
            if [ -e ./parallel/vm${j}/test_logs ]
            then 
                mkdir ./results/${prefixbox}
                mv ./parallel/vm${j}/test_logs/* ./results/${prefixbox}
                mv ./parallel/vm${j}/log.txt ./results/${prefixbox}/log.txt
                mv ./results/${prefixbox}/ruby*.log ./results/${prefixbox}/ruby.txt >/dev/null 2>&1
                mv ./results/${prefixbox}/java*.log ./results/${prefixbox}/java.txt >/dev/null 2>&1
                mv ./results/${prefixbox}/nodejs*.log ./results/${prefixbox}/nodejs.txt >/dev/null 2>&1
                mv ./results/${prefixbox}/php*.log ./results/${prefixbox}/php.txt >/dev/null 2>&1
                mv ./results/${prefixbox}/go*.log ./results/${prefixbox}/go.txt >/dev/null 2>&1
            fi
        done
    fi
done

printf "All done... \n"
printf "The VM's are still suspended...\n"
printf "Some useful commands: \n"
for (( i=1; i<${numboxes}+1; i++ ));
do
    printf "###################################################################\n"
    printf "VAGRANT_CWD=./parallel/vm${i}/ vagrant resume\n"
    printf "VAGRANT_CWD=./parallel/vm${i}/ vagrant ssh\n"
    printf "VAGRANT_CWD=./parallel/vm${i}/ vagrant destroy\n"
    box="${vmboxes[$i-1]}"
    prefixbox=${box////-}
    prefixbox=${prefixbox#"bento-"}
    printf "**** ${prefixbox}'s test reuslts: ./results/${prefixbox} **** \n"
    for j in $(ls ./results/${prefixbox}); do printf "${j} \n"; done
    printf "###################################################################\n"
done

printf "Run sh multi-test.sh cleanup to remove all the VM's and keep ./results \n"
printf "Run sh multi-test.sh reset to remove all the VM's and ./results \n"
