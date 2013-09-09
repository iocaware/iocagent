require "RubyIOC"
require_relative "utils"

module IOCAware
	class Agent

		def initialize(config = {})
			@running = false
			$utils = IOCAware::Utils.new
			$utils.log(config.inspect);
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