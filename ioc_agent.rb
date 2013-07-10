#C:\Sites\IOCAgent>sc \\localhost create IOCAgent binpath= C:\Sites\IOCAgent\ioc_agent.exe start= auto
# Copyright (c) 2013 Matt Jezorek, All Rights Reserved
# Until I figure out what license this will use it is considered DWYW (do what you want)
$LOAD_PATH.unshift File.dirname($0)


require 'rubygems'
require 'RubyIOC'
require 'yaml'
require 'win32/daemon'
require 'multi_json'
require_relative 'scanner'
exit if Object.const_defined?(:Ocra)
CONFIG_FILE = File.dirname(ENV["OCRA_EXECUTABLE"]) + '\\config.yml'

begin
	include Win32

	class IOCAgent < Daemon
		# This method fires off before the service main
		# loop fires. Any pre-setup code should be here
		# 
		def service_init
			$config = YAML.load_file(CONFIG_FILE)
			$scanner = Scanner.new($config)
		end

		# Def this is the daemons main loop This it the code
		# that will run while your service is running
		# loop is not implicit
		def service_main(*args)
			$scanner.log("IOCAgent started at: #{$config['delay']} " + Time.now.to_s)
			$scanner.register
			while running?
				if state == RUNNING
					$scanner.check
					sleep($config['delay'].to_i.minutes)
				else
					# paused or idle
					sleep 0.5
				end
			end
		end

		def service_stop
			$scanner.log("IOCAgent ended at " + Time.now.to_s)
			exit!
		end

		def service_pause
		end

		def service_resume
		end
	end
	IOCAgent.mainloop
rescue Exception => err
	raise
end