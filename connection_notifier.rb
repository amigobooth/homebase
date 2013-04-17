require "bundler"
Bundler.require

api_token = ARGV[0]

raise "You must provide an API token as an argument to this command" if api_token.empty?

module Netstat
  class Parser
    attr_reader :entries

    def initialize
      tcp_states = {
        '00' => 'UNKNOWN',  # Bad state ... Impossible to achieve ...
        'FF' => 'UNKNOWN',  # Bad state ... Impossible to achieve ...
        '01' => 'ESTABLISHED',
        '02' => 'SYN_SENT',
        '03' => 'SYN_RECV',
        '04' => 'FIN_WAIT1',
        '05' => 'FIN_WAIT2',
        '06' => 'TIME_WAIT',
        '07' => 'CLOSE',
        '08' => 'CLOSE_WAIT',
        '09' => 'LAST_ACK',
        '0A' => 'LISTEN',
        '0B' => 'CLOSING'
      }

      single_entry_pattern = Regexp.new(
        /^\s*\d+:\s+(.{8}):(.{4})\s+(.{8}):(.{4})\s+(.{2})\s+.{8}:.{8}\s+.{2}:.{8}\s+.{8}\s+(.{4})/
      )

      @entries = []

      File.open('/proc/net/tcp').each do |i|
        i = i.strip
        if match = i.match(single_entry_pattern)
          entry = Entry.new

          local_ip = match[1].to_i(16)
          entry.local_ip = [local_ip].pack("N").unpack("C4").reverse.join('.')

          entry.local_port = match[2].to_i(16)

          remote_ip = match[3].to_i(16)
          entry.remote_ip = [remote_ip].pack("N").unpack("C4").reverse.join('.')

          entry.remote_port = match[4].to_i(16)

          connection_state = match[5]
          entry.connection_state = tcp_states[connection_state]

          entry.user_id = match[6].to_i

          @entries << entry
        end
      end
    end
  end

  class Entry
    attr_accessor :local_ip, :local_port, :remote_ip, :remote_port, :user_id, :connection_state
  end
end

# When first starting the script, mark ALL devices as disconnected
# http_client = Http.with_headers("X-AmigoBooth-Token" => api_token)
# http_client.post "https://amigobooth.com/api/v1/devices/disconnect_all"

# Start with an empty array of connected device user ids
@connected_device_user_ids = []

# loop do
  # devices = MultiJson.load http_client.get("https://amigobooth.com/api/v1/devices")

  # Iterate over each entry in netstat and mark it connected
  Netstat::Parser.new.entries.each do |e|
    @connected_device_user_ids << e.user_id
  end

  # entries = nil
  # sleep 5
# end

puts @connected_device_user_ids
