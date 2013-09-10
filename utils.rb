require 'json'
require 'net/http'
require "uri"
require "openssl"
require "base64"

# add a to_bool for our strings in the configuration
class String
	def to_bool
  		map = Hash[%w[true yes 1].product([true]) + %w[false no 0].product([false])]
  		map[s.to_s.downcase]
	end
end


module IOCAware
	class Utils
		def initialize(config = {})
			$config = config
		end

		def error(msg)
			File.open($config['working_directory'] + "\\ioc_agent_error.log", 'a') { |f|
				f.puts "[" + Time.now.getutc.to_s + "] ERROR: "  + msg
			}
		end

		def log(msg)
			File.open($config['working_directory'] + "\\ioc_agent.log", 'a') { |f|
				f.puts "[" + Time.now.getutc.to_s + "] "  +  msg
			}
		end

		def get_key
			if !File.exist?($config['working_directory'] + "\\agent.key")
				$utils.log("Going get the key for this agent")
				key = $utils.send_data('/agent/publickey/' + $config['agent_id'] , '')
				File.open($config['working_directory'] + "\\agent.key", "w+") {|f|
					f.write(key)
				}
				return Base64.decode64(key)
			else
				return Base64.decode64(File.read($config['working_directory'] + "\\agent.key"))
			end
		end

		def encrypt_data(data)
			begin
				data = Hash.new
				log(get_key)
				key = OpenSSL::PKey::RSA.new(get_key)
				data['data'] = Base64.encode64(key.public_encrypt(data))
				return data.to_json
			rescue => e
				error(e.backtrace)
				return nil
			end
		end

		def decrypt_data(data)
			begin
				key = OpenSSL::PKey::RSA.new(get_key)
				return Base64.decode64(key.public_decrypt(data))
			rescue => e
				error(e.backtrace)
				return nil
			end
		end

		def send_data(url, data, encrypt = false)
			response = nil
			begin
				wsurl = $config['url'] + url
				uri = URI.parse(wsurl)
				http = Net::HTTP.new(uri.host, uri.port)
				if $config['url'].include?("https")
					http.use_ssl = true
				#	# FIXME: OMG THIS CANT STAY THIS WAY!!!!
					if $config.has_key?('verify_ssl') and !$config['verify_ssl'].to_bool
						http.verify_mode = OpenSSL::SSL::VERIFY_NONE
					end
				end
				request = Net::HTTP::Post.new(uri.request_uri)
				request["Content-Type"] = "application/json"
				if encrypt
					data = encrypt_data(data)
				end
				request.body = data
				response = http.request(request).body
				if encrypt
					response = decrypt_data(response)
				end
			rescue => e
				error(e.backtrace)
			end
			return response
		end

		def get_mac_address
	    	return @mac_address if defined? @mac_address
	    	re = %r/[^:-](?:[0-9A-F][0-9A-F][:-]){5}[0-9A-F][0-9A-F][^:-]/io
	   		cmds = '/sbin/ifconfig', '/bin/ifconfig', 'ifconfig', 'ipconfig /all'

	   		null = test(?e, '/dev/null') ? '/dev/null' : 'NUL'
	   		lines = nil
	    	cmds.each do |cmd|
	      		stdout = IO.popen("#{ cmd } 2> #{ null }"){|fd| fd.readlines} rescue next
	      		next unless stdout and stdout.size > 0
	      		lines = stdout and break
	    	end
	    	raise "all of #{ cmds.join '' } failed" unless lines 

		    candidates = lines.select{|line| line =~ re}
	    	raise 'no mac address candidates' unless candidates.first
	    	candidates.map!{|c| c[re]}

	    	maddr = candidates.first
	    	raise 'no mac address found' unless maddr 

	    	maddr.strip!
	    	maddr.instance_eval{ @list = candidates; def list() @list end }

	    	@mac_address = maddr
  		end
	end
end