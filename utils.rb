module IOCAware
	class Utils
		def initialize(config = {})
			$config = config
		end

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

		def send_data(url, data)
			wsurl = $config[:url] + url
			uri = URI.parse(wsurl)
			http = Net::HTTP.new(uri.host, uri.port)
			#http.use_ssl = true
			# FIXME: OMG THIS CANT STAY THIS WAY!!!!
			#http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Post.new(uri.request_uri)
			request["Content-Type"] = "application/json"
			request.body = data
			response = http.request(request)
			return response
		end
	end
end