#C:\Sites\IOCAgent>sc \\localhost create IOCAgent binpath= C:\Sites\IOCAgent\ioc_agent.exe start= auto
# Copyright (c) 2013 Matt Jezorek, All Rights Reserved
# Until I figure out what license this will use it is considered DWYW (do what you want)

LOG_FILE= 'C:\\Sites\IOCAgent\ioc.log'
CONFIG_FILE = 'C:\\Sites\IOCAgent\config.yml'
require 'rubygems'
require 'RubyIOC'
require 'yaml'
require 'win32/daemon'
require 'multi_json'

exit if Object.const_defined?(:Ocra)

begin
	include Win32

	class IOCAgent < Daemon
		# This method fires off before the service main
		# loop fires. Any pre-setup code should be here
		# 
		def service_init
			$config = YAML.load_file(CONFIG_FILE)
		end

		# Def this is the daemons main loop This it the code
		# that will run while your service is running
		# loop is not implicit
		def service_main(*args)
			File.open(LOG_FILE, 'a') { |f|
				f.puts "IOCAgent started at: #{$config['time']} " + Time.now.to_s
			}
			while running?
				if state == RUNNING
					File.open(LOG_FILE, 'a') { |f|
						f.puts "Checking for IOCs @ " + Time.now.to_s
					}
					sleep($config['time'].to_i.minutes)
				else
					# paused or idle
					sleep 0.5
				end
			end
		end

		def service_stop
			File.open(LOG_FILE, 'a') { |f|
				f.puts "IOCAgent ended at " + Time.now.to_s 
			}
			exit!
		end

		def service_pause
		end

		def service_resume
		end
	end
	IOCAgent.mainloop
rescue Exception => err
	File.open(LOG_FILE, 'a') { | f |
		f.puts 'IOCAgent failure: ' + err.to_s
		raise
	}
end