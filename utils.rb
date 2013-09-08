module IOCAware
	class Utils
		def error(msg)
			File.open(File.dirname(ENV["OCRA_EXECUTABLE"]) + "\\ioc_agent_error.log", 'a') { |f|
				f.puts msg
			}
		end

		def log(msg)
			File.open(File.dirname(ENV["OCRA_EXECUTABLE"]) + "\\ioc_agent.log", 'a') { |f|
				f.puts msg
			}
		end
	end
end