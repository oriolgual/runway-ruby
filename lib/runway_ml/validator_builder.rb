# frozen_string_literal: true

module RunwayML
  # Builds validators from OpenAPI schema definitions
  module ValidatorBuilder
    class << self
      def build_enum_validator(enum_values)
        ->(value, errors, field_name) {
          unless enum_values.include?(value)
            errors[field_name] = "must be one of: #{enum_values.join(', ')}, got #{value.inspect}"
          end
        }
      end

      def build_string_length_validator(min_length: nil, max_length: nil)
        ->(value, errors, field_name) {
          return if value.nil?

          # Handle UTF-16 length for prompt text
          if field_name.to_s.include?("prompt_text") || field_name.to_s.include?("promptText")
            utf16_length = value.encode("UTF-16LE").bytesize / 2
            length = utf16_length
          else
            length = value.to_s.length
          end

          if min_length && length < min_length
            errors[field_name] = "must be at least #{min_length} characters, got #{length}"
          end

          if max_length && length > max_length
            errors[field_name] = "must be at most #{max_length} characters, got #{length}"
          end
        }
      end

      def build_numeric_range_validator(minimum: nil, maximum: nil)
        ->(value, errors, field_name) {
          return if value.nil?

          if minimum && value < minimum
            errors[field_name] = "must be at least #{minimum}, got #{value}"
          end

          if maximum && value > maximum
            errors[field_name] = "must be at most #{maximum}, got #{value}"
          end
        }
      end

      def extract_constraints_from_schema(schema)
        constraints = {}

        if schema["type"] == "string"
          constraints[:string_length] = {
            min_length: schema["minLength"],
            max_length: schema["maxLength"]
          }.compact
        end

        if schema["type"] == "number" || schema["type"] == "integer"
          constraints[:numeric_range] = {
            minimum: schema["minimum"],
            maximum: schema["maximum"]
          }.compact
        end

        if schema["enum"]
          constraints[:enum] = schema["enum"]
        end

        constraints
      end

      def build_from_openapi_property(property_schema, field_name)
        constraints = extract_constraints_from_schema(property_schema)
        validators = []

        if constraints[:enum]
          validators << build_enum_validator(constraints[:enum])
        end

        if constraints[:string_length].any?
          validators << build_string_length_validator(**constraints[:string_length])
        end

        if constraints[:numeric_range].any?
          validators << build_numeric_range_validator(**constraints[:numeric_range])
        end

        validators
      end
    end
  end
end
