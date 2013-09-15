require 'rubygems'
require 'RubyIOC'
require 'win32/daemon'
require 'multi_json'
require 'optparse'
require_relative 'agent'

options = Hash.new
options['working_directory'] = "C:\\Program Files (x86)\\IOCAware"
options['url'] = "http://localhost:3000/"
agent = IOCAware::Agent.new(options)
agent.start