require "RubyIOC"
require 'securerandom'
require_relative "utils"

module IOCAware
	class Agent

		def initialize(config = {})
			@running = false
			$config = config
			check_config # check the configuration and load what we have. 
			$utils = IOCAware::Utils.new($config)
		end

		def check_config
			if !File.exist?($config[:working_directory] + "\\config.yml")
				# configuration does not exist lets make it
				File.open($config[:working_directory] + "\\config.yml", "w+") {|f|
					f.write($config.to_yaml)
				}
			end
			$config = YAML.load_file($config[:working_directory] + "\\config.yml")
			$utils.log($config)
		end


		def start
			@running = true
			while @running
				$utils.log("Running loop")
				sleep 1
			end
		end

		def stop
			@running = false
		end

		def check
			
		end

	end
end