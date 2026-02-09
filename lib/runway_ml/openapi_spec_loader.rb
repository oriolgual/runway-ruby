# frozen_string_literal: true

require "json"
require "uri"
require "net/http"
require "tempfile"
require "fileutils"

module RunwayML
  # Loads and caches the OpenAPI spec from the RunwayML GitHub repository
  class OpenAPISpecLoader
    SPEC_URL = "https://raw.githubusercontent.com/runwayml/openapi/main/openapi.json"
    SPEC_HASH = "9cf1febc614000f72d4332f8bee51b6873b6bce49c9bdc02daae300e6882f9dd"
    CACHE_DIR = File.join(Dir.home, ".cache", "runway-ml-openapi")

    class << self
      attr_accessor :spec

      def load_spec(force_reload: false)
        return @spec if @spec && !force_reload

        @spec = fetch_or_cache_spec(force_reload)
        @spec
      end

      def get_endpoint_schema(method, path)
        load_spec
        path_item = @spec.dig("paths", path)
        return nil unless path_item

        operation = path_item[method.downcase]
        return nil unless operation

        operation
      end

      def get_request_schema(method, path)
        operation = get_endpoint_schema(method, path)
        return nil unless operation

        request_body = operation.dig("requestBody", "content", "application/json", "schema")
        request_body
      end

      def get_response_schema(method, path, status_code = "200")
        operation = get_endpoint_schema(method, path)
        return nil unless operation

        response_schema = operation.dig("responses", status_code, "content", "application/json", "schema")
        response_schema
      end

      def get_path_parameters(method, path)
        operation = get_endpoint_schema(method, path)
        return [] unless operation

        parameters = operation["parameters"] || []
        parameters.select { |p| p["in"] == "path" }
      end

      def get_query_parameters(method, path)
        operation = get_endpoint_schema(method, path)
        return [] unless operation

        parameters = operation["parameters"] || []
        parameters.select { |p| p["in"] == "query" }
      end

      private

      def fetch_or_cache_spec(force_reload)
        if force_reload
          fetch_spec
        else
          cached = load_from_cache
          cached || fetch_and_cache_spec
        end
      end

      def load_from_cache
        cache_file = cache_path
        return nil unless File.exist?(cache_file)

        # Check if cache is less than 24 hours old
        if File.mtime(cache_file) > Time.now - (24 * 3600)
          JSON.parse(File.read(cache_file))
        else
          nil
        end
      rescue StandardError
        nil
      end

      def fetch_and_cache_spec
        spec = fetch_spec
        save_to_cache(spec)
        spec
      end

      def fetch_spec
        uri = URI(SPEC_URL)
        response = Net::HTTP.get(uri)
        JSON.parse(response)
      rescue StandardError => e
        raise "Failed to fetch OpenAPI spec: #{e.message}"
      end

      def save_to_cache(spec)
        FileUtils.mkdir_p(CACHE_DIR)
        File.write(cache_path, JSON.pretty_generate(spec))
      rescue StandardError
        # Silently fail cache writes
      end

      def cache_path
        File.join(CACHE_DIR, "openapi.json")
      end
    end
  end
end
