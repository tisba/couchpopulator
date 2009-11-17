# CouchPopulator: The Idea
The idea behind this tool is to provide a framework for populating your [CouchDB][couchdb] instances with generated documents. It provides a plug-able system for easy writing own generators. Also the the process, which invokes the generator and manages the insertion to CouchDB, what I call execution engines, are easily exchangeable. The default execution engine uses CouchDB's [`bulk-docs`][bulk_api]-API with configurable chunk-size, concurrent inserts and total chunks to insert.

# Warning
This project is in a very early state. I'm sure it has some serious bugs and it's interface and structure for writing own generators and execution engines will definitely change (maybe significantly). I only test it with Ruby 1.8 on OS X 10.6.2.

**Use with caution!**

**BUT**: Please, feel free to comment, fork or fill a ticket with bugs and wishes. You may also drop me a message via GitHub, [@tisba](https://twitter.com/tisba) or at [@couchdb on freenode](irc://irc.freenode.net/couchdb).


# Why?
*"there is tool xy already doing that"* - I don't care (okay, thats not true, I care and I'm always eager to see how others implement stuff). I know that there are some tools providing dumping/loading support for CouchDB. But none is written in ruby and non satisfied my needs (e.g. dynamically generating documents). Nevertheless I wanted to learn how you can write such a tool and get more familiar with CouchDB.


# Getting Started

## Installation

    sudo gem install couchpopulator

## Building the gem yourself

    sudo gem install json trollops
    git clone git@github.com:tisba/couchpopulator.git
    cd couchpopulator
    rake build
      
## Getting help
CouchPopulator tries to give good help on command line options by using:

    couchpopulator --help
    
To get command line options to a specific execution engine, simply use:

    couchpopulator [EXECUTOR] --help

## Custom Generators
Custom generators only need to implement one method. Have a look:

    module CouchPopulator
      module Generators
        class Example
          class << self
            def generate(count)
              # ...heavy generating action goes here...
              # return array of hashes (documents)
            end
          end
        end
      end
    end

generate(count) should return an array of documents. Each document should be an hash that will be encoded in JSON. You can include any object-type you want. CouchPopulator provides some "special" encoding support for Ruby's `time` and `date`. For your own objects you can provide `to_json` and `json_create` used by the [JSON gem][json_gem] to serialise and deserialise it properly.


## Custom Execution Engines
Custom execute engines need to implement two methods `command_line_options` and `execute`. See `executors/standard.rb` for an example.

# Using the CouchPopulator API
This is the very first version of the CouchPopulator API (introduced in v0.2.0). The interface is still very ugly and will change significantly in the future.

The options for `CouchPopulator::Base`'s initializer are the same as the command line options. No rules without exceptions:

* `:logger` needs to be set to a instance of `CouchPopulator::Logger`
* `:generator_klass` needs to be set to the generator constant `CouchPopulator::Initializer.generator()` tries to load it
* `:executor_klass` needs to be set to the executor constant `CouchPopulator::Initializer.executor()` tries to load it

Example:

    require 'rubygems'
    require 'couchpopulator'

    options = { :logger => CouchPopulator::Logger.new,
                :generator_klass => CouchPopulator::Initializer.generator('example'),
                :executor_klass => CouchPopulator::Initializer.executor('standard'),
                :couch => 'http://localhost:5984/test',
                :docs_per_chunk => 1,
                :rounds => 1,
                :concurrent_inserts => 1 }

    CouchPopulator::Base.new(options).populate

# TODO
- make the API suck less
- Add support for using a configuration YAML
- Find out the best strategies for inserting docs to CouchDB and provide execution engines for different approches
- Implement some more features, like dumping-options for generated documents or load dumped JSON docs to CouchDB
- Think about a test suite and implement it
- hunting bugs, make it cleaner



[couchdb]: http://couchdb.apache.org
[bulk_api]: http://wiki.apache.org/couchdb/HTTP_Bulk_Document_API
[json_gem]: http://flori.github.com/json/