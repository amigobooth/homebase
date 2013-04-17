#!/usr/bin/env bash

# Install Packages
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y upgrade

apt-get -y install build-essential bison openssl libreadline6 libreadline6-dev curl wget git-core zlib1g zlib1g-dev libssl-dev libssl0.9.8 libcurl4-openssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev autoconf libc6-dev libncurses5-dev automake libtool imagemagick libmysqlclient-dev mysql-client openjdk-6-jdk pkg-config mdadm libpcre3 libpcre3-dev gdb vim

# Install Ruby
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
exec $SHELL -l
rbenv install 1.9.3-p392
rbenv global 1.9.3-p392

# Install Gems
gem install bundler --no-rdoc --no-ri
gem install chef --no-rdoc --no-ri

# Configure Chef
mkdir -p /etc/chef
mkdir -p /var/log/chef
mkdir -p /root/chef-solo/data_bags
mkdir -p /root/chef-solo/cookbooks

cp -R ./cookbooks /root/chef-solo/cookbooks

echo 'file_cache_path "/root/chef-solo"' > /etc/chef/solo.rb
echo 'data_bag_path "/root/chef-solo/data_bags"' >> /etc/chef/solo.rb
echo 'cookbook_path ["/root/chef-solo/cookbooks"]' >> /etc/chef/solo.rb
echo 'json_attribs "/root/chef-solo/node.json"' >> /etc/chef/solo.rb
echo 'log_location "/var/log/chef/solo.log"' >> /etc/chef/solo.rb
