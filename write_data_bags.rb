require "bundler"
Bundler.require

token = ARGV[0]
output_path = ARGV[1] || Dir.pwd
endpoint = "https://amigobooth.com/api/v1/services/devices"
body = Http.with_headers("X-AmigoBooth-Token" => token).get endpoint

devices = MultiJson.load body

devices.each do |device|
  username = device["id"].gsub("-", "")

  data_bag = Hash.new
  data_bag["id"]         = username
  data_bag["comment"]    = device["description"]
  data_bag["home"]       = "/home/#{username}"
  data_bag["ssh_keys"]   = [device["ssh_public_key"]]
  data_bag["ssh_keygen"] = false

  File.open("#{output_path}/#{username}.json", "w") {|f| f.write(MultiJson.dump(data_bag, pretty: true)) }
end
