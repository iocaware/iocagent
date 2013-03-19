require 'RubyIOC'
class Scanner
	
	def initialize(config = {})
		$config = config
	end

	def run
	end

	def check
		log("Checking for IOCs @ " + Time.now.to_s)
	end

	def log(msg)
		File.open($config['log_file'], 'a') { |f|
			f.puts msg
		}
	end
end