require 'uri'

module CouchPopulator

  class Base
    def initialize(couchdb, executor_klass, options)
      @opts = options
      @couchdb = couchdb
      @logger = options[:logger]
      @executor_klass = executor_klass
    end

    def populate(options)
      options[:logger] ||= @logger
      options[:couch_url] ||= couch_url
      options[:database] ||= database
      log "Invoking #{@executor_klass.to_s}"
      @executor_klass.new.execute(options)
    end

    def log(message)
      @logger.log(message)
    end
    
    def couch_url
      @couch_url ||= @couchdb.match(/^https?:\/\//) ? @couchdb : URI.join('http://127.0.0.1:5984/', @couchdb).to_s
    end

    def database
      URI.parse(couch_url).path
    end

  end


  # Borrowed from Rails
  # http://github.com/rails/rails/blob/ea0e41d8fa5a132a2d2771e9785833b7663203ac/activesupport/lib/active_support/inflector.rb#L355
  class MiscHelper
    class << self
      
      def camelize_and_constantize(lower_case_and_underscored_word)
         constantize(camelize(lower_case_and_underscored_word))
      end
      
      def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
        if first_letter_in_uppercase
          lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
        else
          lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
        end
      end

      # Ruby 1.9 introduces an inherit argument for Module#const_get and
      # #const_defined? and changes their default behavior.
      if Module.method(:const_get).arity == 1
        # Tries to find a constant with the name specified in the argument string:
        #
        #   "Module".constantize     # => Module
        #   "Test::Unit".constantize # => Test::Unit
        #
        # The name is assumed to be the one of a top-level constant, no matter whether
        # it starts with "::" or not. No lexical context is taken into account:
        #
        #   C = 'outside'
        #   module M
        #     C = 'inside'
        #     C               # => 'inside'
        #     "C".constantize # => 'outside', same as ::C
        #   end
        #
        # NameError is raised when the name is not in CamelCase or the constant is
        # unknown.
        def constantize(camel_cased_word)
          names = camel_cased_word.split('::')
          names.shift if names.empty? || names.first.empty?

          constant = Object
          names.each do |name|
            constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
          end
          constant
        end
      else
        def constantize(camel_cased_word) #:nodoc:
          names = camel_cased_word.split('::')
          names.shift if names.empty? || names.first.empty?

          constant = Object
          names.each do |name|
            constant = constant.const_get(name, false) || constant.const_missing(name)
          end
          constant
        end
      end
    end
  end

  class CouchHelper
    class << self
      
      def get_full_couchurl(arg)
        arg.match(/^https?:\/\//) ? arg : URI.join('http://127.0.0.1:5984/', arg).to_s
      end
      
      def couch_available? (couch_url)
        # TODO this uri-thing is ugly :/
        tmp = URI.parse(couch_url)
        `curl --fail --request GET #{tmp.scheme}://#{tmp.host}:#{tmp.port} 2> /dev/null`
        return $?.exitstatus == 0
      end
      
      def database_exists? (db_url)
        `curl --fail --request GET #{db_url} 2> /dev/null`
        return $?.exitstatus == 0
      end

      def create_db(url)
        !!(JSON.parse(`curl --silent --write-out %{http_code} --request PUT #{url}`))["ok"]
      end
    end
  end
  
end

