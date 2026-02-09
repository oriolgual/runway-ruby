# frozen_string_literal: true

require_relative "openapi_spec_loader"

module RunwayML
  # Helps validate SDK requests and responses against the OpenAPI spec
  class ContractValidator
    def initialize
      @spec = OpenAPISpecLoader.load_spec
    end

    # Validates that a request body conforms to the OpenAPI spec
    def validate_request(method, path, request_body)
      schema = OpenAPISpecLoader.get_request_schema(method, path)
      return { valid: true } unless schema

      # Try to validate using JSON Schema
      errors = validate_against_schema(request_body, schema, "Request")
      errors.empty? ? { valid: true } : { valid: false, errors: errors }
    rescue StandardError => e
      { valid: false, errors: [ e.message ] }
    end

    # Validates that a response body conforms to the OpenAPI spec
    def validate_response(method, path, response_body, status_code = 200)
      schema = OpenAPISpecLoader.get_response_schema(method, path, status_code.to_s)
      return { valid: true } unless schema

      errors = validate_against_schema(response_body, schema, "Response")
      errors.empty? ? { valid: true } : { valid: false, errors: errors }
    rescue StandardError => e
      { valid: false, errors: [ e.message ] }
    end

    # Validates a value against a schema with discriminator support
    def validate_discriminated_oneOf(value, schema, discriminator_field)
      return { valid: true } unless schema.dig("oneOf")

      discriminator_value = value[discriminator_field]
      return { valid: false, errors: [ "Missing discriminator field: #{discriminator_field}" ] } unless discriminator_value

      matching_schemas = schema["oneOf"].select do |s|
        s.dig("properties", discriminator_field, "const") == discriminator_value ||
          s["title"] == discriminator_value
      end

      return { valid: false, errors: [ "No matching schema for #{discriminator_field}: #{discriminator_value}" ] } if matching_schemas.empty?

      # Validate against the first matching schema
      errors = validate_against_schema(value, matching_schemas.first, "Discriminated Schema")
      errors.empty? ? { valid: true } : { valid: false, errors: errors }
    end

    def validate_against_schema(data, schema, context = "Schema")
      return [] if schema.nil?

      errors = []

      # Handle oneOf schemas (discriminated unions)
      if schema["oneOf"]
        model_value = data[schema["discriminator"]["propertyName"]] if schema["discriminator"]
        matching_schemas = schema["oneOf"].select do |s|
          s.dig("properties", schema["discriminator"]["propertyName"], "const") == model_value ||
            s["title"] == model_value
        end

        if matching_schemas.any?
          errors.concat(validate_against_schema(data, matching_schemas.first, context))
          return errors
        else
          return [ "#{context}: No matching schema for model: #{model_value}" ]
        end
      end

      # Basic type checking
      if schema["type"]
        unless matches_type?(data, schema["type"])
          errors << "#{context}: Expected type #{schema['type']}, got #{data.class.name.downcase}"
        end
      end

      # String constraints
      if schema["type"] == "string" && data.is_a?(String)
        if schema["minLength"] && data.length < schema["minLength"]
          errors << "#{context}: String too short (minimum #{schema['minLength']} characters)"
        end
        if schema["maxLength"] && data.length > schema["maxLength"]
          errors << "#{context}: String too long (maximum #{schema['maxLength']} characters)"
        end
        if schema["pattern"] && !data.match?(Regexp.new(schema["pattern"]))
          errors << "#{context}: String does not match pattern #{schema['pattern']}"
        end
      end

      # Numeric constraints
      if (schema["type"] == "number" || schema["type"] == "integer") && data.is_a?(Numeric)
        if schema["minimum"] && data < schema["minimum"]
          errors << "#{context}: Number below minimum #{schema['minimum']}"
        end
        if schema["maximum"] && data > schema["maximum"]
          errors << "#{context}: Number above maximum #{schema['maximum']}"
        end
      end

      # Enum validation
      if schema["enum"] && !schema["enum"].include?(data)
        errors << "#{context}: #{data.inspect} not in enum #{schema['enum']}"
      end

      # Required fields for objects
      if schema["type"] == "object" && data.is_a?(Hash)
        required_fields = schema["required"] || []
        missing_fields = required_fields.reject { |f| data.key?(f) || data.key?(f.to_sym) }
        if missing_fields.any?
          errors << "#{context}: Missing required fields: #{missing_fields.join(', ')}"
        end

        # Validate properties if defined
        properties = schema["properties"] || {}
        properties.each do |prop_name, prop_schema|
          value = data[prop_name] || data[prop_name.to_sym]
          next unless value

          prop_errors = validate_against_schema(value, prop_schema, "#{context}.#{prop_name}")
          errors.concat(prop_errors)
        end
      end

      errors
    end

    def matches_type?(data, type)
      case type
      when "string"
        data.is_a?(String)
      when "number"
        data.is_a?(Numeric)
      when "integer"
        data.is_a?(Integer)
      when "boolean"
        data.is_a?(TrueClass) || data.is_a?(FalseClass)
      when "object"
        data.is_a?(Hash)
      when "array"
        data.is_a?(Array)
      else
        true
      end
    end
  end
end
