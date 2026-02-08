require "net/http"
require "json"
require "uri"
require "openssl"

module RunwayML
  class Client
    def initialize(api_secret:, base_url: "https://api.dev.runwayml.com/v1/", api_version: "2024-11-06")
      @api_secret = api_secret
      @base_url = base_url
      @api_version = api_version
    end

    def post(path, params)
      request(:post, path, params)
    end

    def get(path)
      request(:get, path)
    end

    def delete(path)
      request(:delete, path)
    end

    private

    attr_reader :api_secret, :base_url, :api_version

    def request(method, path, params = nil)
      uri = URI("#{base_url}#{path}")

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = build_request(method, uri, params)
        response = http.request(request)
        body = parse_body(response)

        unless response.is_a?(Net::HTTPSuccess)
          headers = response.to_hash.transform_keys(&:downcase)
          error_message = body.is_a?(Hash) ? body["error"] : nil
          raise APIError.generate(response.code.to_i, body, error_message, headers)
        end

        body
      end
    rescue OpenSSL::SSL::SSLError => e
      raise SSLError.new(message: e.message, cause: e)
    rescue SocketError, Net::OpenTimeout, Net::ReadTimeout => e
      raise APIConnectionError.new(message: e.message, cause: e)
    end

    def build_request(method, uri, params)
      request_class = case method
      when :get
        Net::HTTP::Get
      when :post
        Net::HTTP::Post
      when :delete
        Net::HTTP::Delete
      else
        raise ArgumentError, "Unsupported HTTP method: #{method}"
      end

      request = request_class.new(uri)
      request["Authorization"] = "Bearer #{api_secret}"
      request["X-Runway-Version"] = api_version

      if method == :post
        request["Content-Type"] = "application/json"
        request.body = JSON.generate(params || {})
      end

      request
    end

    def parse_body(response)
      return nil if response.body.nil? || response.body.strip.empty?

      JSON.parse(response.body)
    rescue JSON::ParserError
      nil
    end
  end
end
