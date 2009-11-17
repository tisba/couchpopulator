require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "couchpopulator"
    gemspec.summary = "Flexible tool for populating CouchDB with generated documents"
    gemspec.description = "The idea behind this tool is to provide a framework for populating your CouchDB instances with generated documents. It provides a plug-able system for easy writing own generators. Also the the process, which invokes the generator and manages the insertion to CouchDB, what I call execution engines, are easily exchangeable. The default execution engine uses CouchDB's bulk-docs-API with configurable chunk-size, concurrent inserts and total chunks to insert."
    gemspec.email = "sebastian.cohnen@gmx.net"
    gemspec.homepage = "http://github.com/tisba/couchpopulator"
    gemspec.authors = ["Sebastian Cohnen"]
    
    gemspec.files = []
    gemspec.files = FileList['lib/**/*.rb'] +
                    FileList['executors/**/*.rb'] +
                    FileList['generators/**/*.rb'] +
                    FileList['bin/*']

    gemspec.has_rdoc = false

    gemspec.executables = 'couchpopulator'
    
    gemspec.require_paths << 'lib'
    gemspec.require_paths << 'generators'
    gemspec.require_paths << 'executors'
    
    gemspec.add_dependency('json', '>=1.2.0')
    gemspec.add_dependency('trollop', '>=1.15')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end