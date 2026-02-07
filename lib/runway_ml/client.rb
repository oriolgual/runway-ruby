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

    def image_to_video
      ImageToVideo.new(client: self)
    end

    def post(path, params)
      uri = URI("#{base_url}#{path}")

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{api_secret}"
        request["X-Runway-Version"] = api_version
        request.body = JSON.generate(params)

        response = http.request(request)
        body = JSON.parse(response.body) rescue nil

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

    private

    attr_reader :api_secret, :base_url, :api_version
  end
end
