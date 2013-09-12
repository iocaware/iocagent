# 
# ocra --output iocaware.exe --no-autoload .\ioc_agent.rb .\scanner.rb --
# msiexec /i iocaware.msi SERVERURL="http://localhost:3000/
# 'C:\Program Files (x86)\WiX Toolset v3.7\bin\candle' .\iocaware.wxs
# 'C:\Program Files (x86)\WiX Toolset v3.7\bin\light' .\iocaware.wixobj
# Copyright (c) 2013 Matt Jezorek, All Rights Reserved
# Until I figure out what license this will use it is considered DWYW (do what you want)
require 'rubygems'
require 'RubyIOC'
require 'win32/daemon'
require 'multi_json'
require 'optparse'
require_relative 'agent'


Dir.chdir File.dirname($0) # change directory back to where it was
exit if Object.const_defined?(:Ocra)

begin
	include Win32

	class IOCAgent < Daemon
		# This method fires off before the service main
		# loop fires. Any pre-setup code should be here
		# 

		def service_init(*args)
			@options = {}
			@options['working_directory'] = File.dirname(ENV["OCRA_EXECUTABLE"])
			opts = OptionParser.new do | parser | 
				parser.on("-u", "--url [STR]", "This is the url that the server is listening on") do | setting |
					@options['url'] = setting
				end
			end
			opts.parse!
			begin
				$agent = IOCAware::Agent.new(@options)
			rescue => e
				File.open(@options['working_directory'] + "\\ioc_agent_error.log", 'a') { |f|
					f.puts "[" + Time.now.getutc.to_s + "] ERROR: "  + e.inspect  + " "  +  caller.inspect
				}
			end
		end

		# Def this is the daemons main loop This it the code
		# that will run while your service is running
		# loop is not implicit
		def service_main(*args)
			$agent.start
		end

		def service_stop
			$agent.stop
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