require 'rubygems'
require 'trollop'
require 'uri'

require 'json/add/rails'
require 'json/add/core'

require File.join(File.dirname(__FILE__), 'couchpopulator.rb')
require File.join(File.dirname(__FILE__), 'curl_adapter.rb')
require File.join(File.dirname(__FILE__), 'generator.rb')
require File.join(File.dirname(__FILE__), 'logger.rb')

Dir.glob(File.join(File.dirname(__FILE__), 'couchpopulator/*.rb')).each {|f| require f }