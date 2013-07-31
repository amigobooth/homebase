require "fileutils"
require "bundler"
Bundler.require

api_token = ARGV[0]

raise "You must provide an API token as an argument to this command" if api_token.nil? or api_token.empty?

chef_root_dir = ARGV[1] || Dir.pwd
FileUtils.mkdir_p "#{chef_root_dir}/data_bags/users"
endpoint = "https://amigobooth.com/api/v1/services/devices"
body = Http.with_headers("X-AmigoBooth-Token" => api_token).get endpoint

devices = MultiJson.load body

data_bag_users = []

devices.each do |device|
  hardware_address = device["hardware_address"]

  data_bag = Hash.new
  data_bag["id"]         = hardware_address
  data_bag["comment"]    = device["description"]
  data_bag["home"]       = "/home/#{hardware_address}"
  data_bag["ssh_keys"]   = [%(no-agent-forwarding,no-X11-forwarding,no-pty,command="/bin/false" ) + device["ssh_public_key"]]
  data_bag["ssh_keygen"] = "false"
  data_bag["shell"]      = "/usr/sbin/nologin"
  data_bag["uid"]        = device["uid"]

  File.open("#{chef_root_dir}/data_bags/users/#{hardware_address}.json", "w") {|f| f.write(MultiJson.dump(data_bag, pretty: true)) }
  data_bag_users << hardware_address
end

node_info = {
  run_list: ["user::data_bag"],
  users: data_bag_users
}

File.open("#{chef_root_dir}/node.json", "w") {|f| f.write(MultiJson.dump(node_info, pretty: true)) }
