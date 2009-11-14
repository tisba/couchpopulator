class CurlAdapter
  class Response
    attr_reader :http_response_code
    attr_reader :time_total

    def initialize(http_response_code, time_total)
      @http_response_code = http_response_code
      @time_total = time_total
    end

    def inspect
      "#{@http_response_code} #{@time_total} sec"
    end
  end

  class Invoker
    attr_reader :db_url

    def initialize(db_url)
      @db_url = db_url
    end

    def post(payload)
      cmd = "curl -T - -X POST #{@db_url}/_bulk_docs -w\"%{http_code}\ %{time_total}\" -o out.file 2> /dev/null"
      curl_io = IO.popen(cmd, "w+")
      curl_io.puts payload
      curl_io.close_write
      result = CurlAdapter::Response.new(*curl_io.gets.split(" "))
    end
  end
end

# TODO:
# Keep-Alive mit curl? wäre geil...


