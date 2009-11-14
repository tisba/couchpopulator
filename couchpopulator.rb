#! /usr/bin/ruby
require "rubygems"
require 'trollop'

require 'json/add/rails'
require 'json/add/core'

require File.join(File.dirname(__FILE__), '/lib/core_ext/object')
require File.join(File.dirname(__FILE__), '/lib/core_ext/time')
require File.join(File.dirname(__FILE__), '/lib/core_ext/date')
require File.join(File.dirname(__FILE__), '/lib/core_ext/string')
require File.join(File.dirname(__FILE__), '/lib/core_ext/symbol')

# load all "libs"
Dir.glob(File.join(File.dirname(__FILE__), 'lib/*.rb')).each {|f| require f }

# load all generators
Dir.glob(File.join(File.dirname(__FILE__), 'generators/*.rb')).each {|f| require f }

# load all executors
Dir.glob(File.join(File.dirname(__FILE__), 'executors/*.rb')).each {|f| require f }

# Define some command-line options
opts = Trollop.options do
  version "v1.0 (c) Sebastian Cohnen, 2009"
  banner <<-BANNER
  This is a simple, yet powerfull tool to import large numbers of on-the-fly generated documents into CouchDB.
  It's using concurrency by spawning several curl subprocesses. Documents are generated on-the-fly.

  See http://github.com/tisba/couchpopulator for more information.
  
  Usage:
  ./couchpopulator [OPTIONS] [executor [EXECUTOR-OPTIONS]]
  
  To see, what options for 'executor' are:
  ./couchpopulator executor -h
  
  BANNER
  opt :couch, "URL of CouchDB Server. You can also provide the name of the target DB only, http://localhost:5984/ will be prepended automatically", :default => ""
  opt :create_db, "Create DB if needed.", :default => false
  opt :generator, "Name of the generator-class to use", :default => "Event"
  opt :generate_only, "Generate the docs, but don't write to couch and stdout them instead", :default => false
  opt :logfile, "Redirect info/debug output to specified file instead to stdout", :type => String, :default => ""
  stop_on_unknown
end

# Get the requested generator or die
generator_klass = CouchPopulator::MiscHelper.camelize_and_constantize("generators/#{opts[:generator]}") rescue generator_klass = nil
Trollop.die :generator, "Generator must be set, a valid class-name and respond to generate(n)" if generator_klass.nil? || generator_klass.methods.member?(:generate)

# Get the exexcutor (defaults to standard) or die
executor_klass = CouchPopulator::MiscHelper.camelize_and_constantize("executors/#{ARGV.shift || "standard"}") rescue executor_klass = nil
Trollop.die "Executor must be set and a valid class-name" if executor_klass.nil?

# Build the full CouchDB database url
couch_url = CouchPopulator::CouchHelper.get_full_couchurl(opts[:couch])

# Check for availabilty of couchdb
Trollop.die :couch, "#{couch_url} is not reachable or ressource does not exist" unless CouchPopulator::CouchHelper.couch_available? couch_url

# create database on demand
if opts[:create_db]
  # CouchPopulator::Helper.create_db(opts[:couch]) 
else
  CouchPopulator::Helper.database_exists? db_url
end


# Initialize CouchPopulator
cp = CouchPopulator::Base.new(opts[:couch], executor_klass, :logger => CouchPopulator::Logger.new(opts[:logfile]))

# invoke the populator
cp.populate(:generator => generator_klass)