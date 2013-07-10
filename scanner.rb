require 'RubyIOC'
require 'sys/host'
require 'sys/uname'
require 'json'
require 'net/http'
require "uri"

include Sys

class Scanner
	
	def initialize(config = {})
		$config = config
		# lets register each time it comes up so that we can have IP information etc for each agent 
		$ip = Host.ip_addr.join(", ")
		$mac = mac_address
		$hostname = Host.hostname
		$os = Uname.sysname
		$osversion = Uname.version
	end

	def send_data(url, data)
		wsurl = $config['url'] + url
		uri = URI.parse(wsurl)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		# FIXME: OMG THIS CANT STAY THIS WAY!!!!
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Post.new(uri.request_uri)
		request["Content-Type"] = "application/json"
		request.body = data
		response = http.request(request)
		return response
	end

	def run
	end

	def check
		begin
			log("Checking for IOCs @ " + Time.now.to_s)
			data = {
				'aid' => $config['aid'],
				'job' => 'checkjobs'
			}.to_json
			r = send_data('/api/checkjobs/' + $config['aid'], data)
			log(r)
			# Perform check to the IOC Control Panel
		rescue StandardError => omg
			error("Error running iocagent: " + omg)
		end
	end


	def register
		begin
			agent = {
				'ip' => $ip,
				'mac' => $mac,
				'hostname' => $hostname,
				'os' => $os,
				'osversion' => $osversion,
				'aid' => $config['aid']
			}.to_json
			log("Registering IOCAgent on #{agent}")
			send_data('/api/register/' + $config['aid'], agent)
		rescue StandardError => omg
			error("Error running iocagent: " + omg)
		end
	end
	
	def error(msg)
		File.open(File.dirname(ENV["OCRA_EXECUTABLE"]) + "\\" + $config['log'], 'a') { |f|
				f.puts msg
		}
	end

	def log(msg)
		if $config['debug']
			File.open(File.dirname(ENV["OCRA_EXECUTABLE"]) + "\\" + $config['log'], 'a') { |f|
				f.puts msg
			}
		end
	end

	def mac_address
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