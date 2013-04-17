require "fileutils"
require "bundler"
Bundler.require

token = ARGV[0]
chef_root_dir = ARGV[1] || Dir.pwd
FileUtils.mkdir_p "#{chef_root_dir}/data_bags/users"
endpoint = "https://amigobooth.com/api/v1/services/devices"
body = Http.with_headers("X-AmigoBooth-Token" => token).get endpoint

devices = MultiJson.load body

data_bag_users = []

devices.each do |device|
  username = device["id"].gsub("-", "")

  data_bag = Hash.new
  data_bag["id"]         = username
  data_bag["comment"]    = device["description"]
  data_bag["home"]       = "/home/#{username}"
  data_bag["ssh_keys"]   = [device["ssh_public_key"]]
  data_bag["ssh_keygen"] = "false"
  data_bag["shell"]      = "/usr/sbin/nologin"
  data_bag["uid"]        = device["uid"]

  File.open("#{chef_root_dir}/data_bags/users/#{username}.json", "w") {|f| f.write(MultiJson.dump(data_bag, pretty: true)) }
  data_bag_users << username
end

node_info = {
  run_list: ["user::data_bag"],
  users: data_bag_users
}

File.open("#{chef_root_dir}/node.json", "w") {|f| f.write(MultiJson.dump(node_info, pretty: true)) }
