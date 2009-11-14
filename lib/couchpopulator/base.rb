module CouchPopulator
  class Base
    def initialize(couchdb, options)
      @opts = options
      @opts[:couch_url] = CouchHelper.get_full_couchurl couchdb
      @logger = options[:logger]
    end

    def populate
      @opts[:logger] ||= @logger
      
      @opts[:database] ||= database
      log "Invoking execution engine #{@opts[:executor_klass].to_s}"
      
      @opts[:executor_klass].new(@opts).execute
    end

    def log(message)
      @logger.log(message)
    end
    
    def database
      URI.parse(@opts[:couch_url]).path
    end
  end
end