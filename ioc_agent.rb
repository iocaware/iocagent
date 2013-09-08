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
require_relative 'agent'

exit if Object.const_defined?(:Ocra)
DEBUG = true

begin
	include Win32

	class IOCAgent < Daemon
		# This method fires off before the service main
		# loop fires. Any pre-setup code should be here
		# 
		def service_init(*args)
			$agent = IOCAware::Agent.new
		end

		# Def this is the daemons main loop This it the code
		# that will run while your service is running
		# loop is not implicit
		def service_main(*args)
			$agent.start
		end

		def service_stop
			$agent.stop
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