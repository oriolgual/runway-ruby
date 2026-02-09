# frozen_string_literal: true

module RunwayML
  # Analyzes coverage of SDK methods against OpenAPI spec endpoints
  class SpecCoverageAnalyzer
    CRITICAL_ENDPOINTS = {
      "POST /v1/text_to_video" => { class: "TextToVideo", method: "create" },
      "POST /v1/image_to_video" => { class: "ImageToVideo", method: "create" },
      "POST /v1/text_to_speech" => { class: "TextToSpeech", method: "create" },
      "POST /v1/speech_to_speech" => { class: "SpeechToSpeech", method: "create" },
      "POST /v1/sound_effect" => { class: "SoundEffect", method: "create" },
      "POST /v1/voice_isolation" => { class: "VoiceIsolation", method: "create" },
      "POST /v1/voice_dubbing" => { class: "VoiceDubbing", method: "create" },
      "POST /v1/character_performance" => { class: "CharacterPerformance", method: "create" },
      "POST /v1/video_to_video" => { class: "VideoToVideo", method: "create" },
      "POST /v1/text_to_image" => { class: "TextToImage", method: "create" },
      "GET /v1/tasks/{id}" => { class: "Task", method: "retrieve" },
      "DELETE /v1/tasks/{id}" => { class: "Task", method: "delete" },
      "GET /v1/organization" => { class: "Organization", method: "retrieve" },
      "POST /v1/uploads" => { class: "Uploads", method: "create" }
    }

    class << self
      def analyze
        spec = OpenAPISpecLoader.load_spec
        return nil unless spec

        coverage = {}

        CRITICAL_ENDPOINTS.each do |endpoint, info|
          method, path = endpoint.split(" ")
          schema = OpenAPISpecLoader.get_endpoint_schema(method, path)

          coverage[endpoint] = {
            sdk_class: info[:class],
            sdk_method: info[:method],
            spec_exists: !schema.nil?,
            has_request_schema: has_request_schema_for_endpoint?(method, path),
            has_response_schema: has_response_schema_for_endpoint?(method, path),
            models_supported: extract_supported_models(schema, path),
            path_object: schema
          }
        end

        coverage
      end

      def print_coverage_report
        coverage = analyze
        return puts "Could not load OpenAPI spec" unless coverage

        puts "\n" + "=" * 100
        puts "SDK SPEC COVERAGE REPORT".center(100)
        puts "=" * 100 + "\n"

        total_endpoints = coverage.size
        fully_compliant = coverage.count { |_, v| v[:spec_exists] && v[:has_request_schema] && v[:has_response_schema] }

        puts "Summary:"
        puts "  Total Critical Endpoints: #{total_endpoints}"
        puts "  Fully Defined in Spec: #{fully_compliant}/#{total_endpoints}"
        puts "  Compliance Rate: #{(fully_compliant.to_f / total_endpoints * 100).round(1)}%\n\n"

        puts "Endpoint Details:"
        puts "-" * 100

        coverage.each do |endpoint, data|
          status = data[:spec_exists] ? "✓" : "✗"
          models = data[:models_supported].any? ? " [Models: #{data[:models_supported].join(', ')}]" : ""

          puts "#{status} #{endpoint.ljust(35)} -> #{data[:sdk_class]}.#{data[:sdk_method]}#{models}"

          unless data[:spec_exists]
            puts "    ⚠️  Endpoint not found in OpenAPI spec"
          else
            unless data[:has_request_schema]
              puts "    ⚠️  Missing request schema (expected for GET/DELETE)"
            end
            unless data[:has_response_schema]
              puts "    ⚠️  Missing response schema"
            end
          end
        end

        puts "\n" + "=" * 100 + "\n"
      end

      private

      def has_request_schema_for_endpoint?(method, path)
        # GET and DELETE methods don't have request bodies, so skip schema check
        return true if method.upcase == "GET" || method.upcase == "DELETE"

        OpenAPISpecLoader.get_request_schema(method, path) != nil
      end

      private

      def has_request_schema_for_endpoint?(method, path)
        # GET and DELETE methods don't have request bodies, so skip schema check
        return true if method.upcase == "GET" || method.upcase == "DELETE"

        OpenAPISpecLoader.get_request_schema(method, path) != nil
      end

      def has_response_schema_for_endpoint?(method, path)
        # 204 No Content responses are valid without a schema
        operation = OpenAPISpecLoader.get_endpoint_schema(method, path)
        return true unless operation

        responses = operation["responses"] || {}

        # Check if 204 No Content is defined (DELETE endpoints)
        return true if responses.key?("204")

        # Otherwise check for response schema
        OpenAPISpecLoader.get_response_schema(method, path) != nil
      end

      def extract_supported_models(schema, path)
        return [] unless schema

        # For endpoints with oneOf discriminated by model
        request_schema = schema.dig("requestBody", "content", "application/json", "schema")
        return [] unless request_schema&.dig("oneOf")

        request_schema["oneOf"].map do |variant|
          variant.dig("properties", "model", "const") ||
            variant.dig("title")
        end.compact
      end
    end
  end
end
