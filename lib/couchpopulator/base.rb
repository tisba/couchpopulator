module CouchPopulator
  class Base
    def initialize(options)
      @opts = options
      @opts[:couch_url] = CouchHelper.get_full_couchurl options[:couch] unless options[:couch].nil?
      @logger = options[:logger]
    end

    def populate
      @opts[:logger] ||= @logger

      @opts[:database] ||= database
      @opts[:executor_klass].new(@opts).execute
    end

    def log(message)
      @logger.log(message)
    end

    def database
      URI.parse(@opts[:couch_url]).path unless @opts[:couch_url].nil?
    end
  end
end