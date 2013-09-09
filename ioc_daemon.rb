$LOAD_PATH.unshift File.dirname($0)
require 'rubygems'
require 'RubyIOC'
require 'yaml'
require 'daemons'
require_relative 'scanner'
CONFIG_FILE = 'config.yml'


class IOCDaemon
	def initialize
		$config = YAML.load_file(CONFIG_FILE)
		$scanner = Scanner.new($config)
	end

	def run
		$scanner.log("IOCAgent started at: #{$config['delay']} " + Time.now.to_s)
		$scanner.register
		Daemons.daemonize
		while true
			$scanner.check
			sleep($config['delay'].to_i.minutes)
		end
	end
end

iocagent = IOCDaemon.new
iocagent.run()
