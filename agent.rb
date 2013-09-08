require "RubyIOC"
require_relative "utils"

module IOCAware
	class Agent

		def initialize
			@running = false
			$utils = IOCAware::Utils.new
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