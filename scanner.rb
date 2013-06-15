require 'RubyIOC'
require 'sys/host'
require 'sys/uname'
include Sys

class Scanner
	
	def initialize(config = {})
		$config = config
		# lets register each time it comes up so that we can have IP information etc for each agent 
		$ip = Host.ip_addr[0]
		$mac = Host.ip_addr[1]
		$hostname = Host.hostname
		$os = Uname.sysname
		$osversion = Uname.version
	end

	def run
	end

	def check
		log("Checking for IOCs @ " + Time.now.to_s)
		# Perform check to the IOC Control Panel
	end


	def register
		log("Registering IOCAgent on #{$hostname} (#{$ip}) (#{$mac})- #{$os} (#{$osversion})")
	end
	
	def log(msg)
		File.open($config['log_file'], 'a') { |f|
			f.puts msg
		}
	end
end