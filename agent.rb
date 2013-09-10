require "RubyIOC"
require 'securerandom'
require 'sys/host'
require 'sys/uname'
require 'openssl'

require_relative "utils"
include Sys

module IOCAware
	class Agent

		def initialize(config = {})
			@running = false
			$config = config
			$utils = nil
			check_config # check the configuration and load what we have.
			get_host_data # get ip and os version information
			register # register the agent
		end

		def check_config
			if !File.exist?($config['working_directory'] + "\\config.yml")
				# configuration does not exist lets make it
				$config['agent_id'] = SecureRandom.uuid
				File.open($config['working_directory'] + "\\config.yml", "w+") {|f|
					f.write($config.to_yaml)
				}
			end
			# FIXME: lets do a hash and not write everytime nothing has changed.
			$config = YAML.load_file($config['working_directory'] + "\\config.yml")
			$utils = IOCAware::Utils.new($config)
			$utils.log('Checking the agent settings and refreshing')
			# we have a configuration from our file. Lets get a current configuration
			data = Hash.new
			begin
				response = $utils.send_data('/agent/configure', '')
				data = JSON.parse(response)
			rescue => e
				$utils.error(e.backtrace)
			end
			$config = $config.deep_merge(data)
			File.open($config['working_directory'] + "\\config.yml", "w+") {|f|
				f.write($config.to_yaml)
			}
			$config = YAML.load_file($config['working_directory'] + "\\config.yml")
		end

		def get_host_data
			begin
				$host = Hash.new
				$host['ip'] = Host.ip_addr.join(", ")
				$host['mac'] = $utils.get_mac_address
				$host['hostname'] = Host.hostname
				$host['os'] = Uname.sysname
				$host['osv'] = Uname.version
			rescue => e
				$utils.error(e.backtrace)
			end
		end

		def sleep_break(seconds) 
			while(seconds > 0) 
				sleep(1)
				seconds -= 1
				break unless @running
			end
		end

		def start
			@running = true
			$utils.log("Starting IOCAware agent")
			i = $config['check_settings'].to_i
			begin
				loop do 
					break if !@running
					sleep_break($config['check_time'].to_i*60)
					i -= 1
					next unless i.zero?
					# lets check the configuration and update it.
					i = $config['check_settings'].to_i
					check_config
				end
			rescue => e
				$utils.error(e.backtrace)
			end
		end

		def stop
			@running = false
			exit!
		end

		def register
			data = $host
			data['agent_id'] = $config['agent_id']
			begin
				$utils.log(data.to_json)
				$utils.send_data('/agent/register/' + $config['agent_id'], data.to_json, true)
			rescue => ex
				$utils.error(ex.backtrace)
			end
		end

		def check
			
		end

	end
end