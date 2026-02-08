module RunwayML
  class TestClient
    def initialize(api_secret: nil, base_url: nil, api_version: nil)
      reset!
    end

    def post(path, params)
      record_request(:post, path, params)
      fetch_response(:post, path, params)
    end

    def get(path)
      record_request(:get, path, nil)
      fetch_response(:get, path)
    end

    def delete(path)
      record_request(:delete, path, nil)
      fetch_response(:delete, path)
    end

    # Inject a response for a given method/path/params
    def inject_response(method, path, params: nil, response:)
      key = response_key(method, path, params)
      @responses[key] = response
    end

    def requests
      @requests.dup
    end

    def reset!
      @responses = {}
      @requests = []
    end

    private

    def fetch_response(method, path, params = nil)
      key = response_key(method, path, params)
      unless @responses.key?(key)
        raise "No injected response for #{method.upcase} #{path} with params: #{params.inspect}"
      end
      response = @responses[key]
      if response.is_a?(Array)
        raise "No injected response remaining for #{method.upcase} #{path} with params: #{params.inspect}" if response.empty?
        response = response.shift
      end
      raise response if response.is_a?(Exception)

      response
    end

    def record_request(method, path, params)
      @requests << { method: method, path: path, params: params }
    end

    def response_key(method, path, params)
      [ method, path, params ]
    end
  end
end
