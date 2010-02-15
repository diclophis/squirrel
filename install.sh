#!/bin/sh

sudo apt-get install build-essential ruby ri rdoc irb ruby-dev mysql-client mysql-server memcached libmysqlclient-dev git-core imagemagick libmagick9-dev libopenssl-ruby1.8

sudo ln -s /usr/bin/gem1.8 /usr/local/bin/gem
sudo ln -s /usr/bin/ruby1.8 /usr/local/bin/ruby
sudo ln -s /usr/bin/rdoc1.8 /usr/local/bin/rdoc
sudo ln -s /usr/bin/ri1.8 /usr/local/bin/ri
sudo ln -s /usr/bin/irb1.8 /usr/local/bin/irb
