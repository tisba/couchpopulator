module CouchPopulator
  # Borrowed from Rails
  # http://github.com/rails/rails/blob/ea0e41d8fa5a132a2d2771e9785833b7663203ac/activesupport/lib/active_support/inflector.rb#L355
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