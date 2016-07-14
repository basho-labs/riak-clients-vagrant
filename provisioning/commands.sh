vagrant up
vagrant ssh

ansible-playbook /vagrant/provisioning/playbook.yml --connection=local

# PHP HTTP
cd ~/code/riak-php-client
composer update
./vendor/bin/phpunit

# PHP PB
cp ~/code/riak-phppb-client/vendor/allegro/protobuf /tmp/
cd /tmp/protobuf
phpize
./configure
make
sudo make install
cd ~/code/riak-phppb-client
composer update
./vendor/bin/phpunit

# Go
cd ~/code/riak-go-client
"host" go get -u -v
go test -v -tags=integration

# Java
cd ~/code/riak-java-client
mvn clean install -Pitest -Dcom.basho.riak.2i=true -Dcom.basho.riak.yokozuna=true -Dcom.basho.riak.buckettype=true -Dcom.basho.riak.crdt=true

# Node
cd ~/code/riak-nodejs-client

