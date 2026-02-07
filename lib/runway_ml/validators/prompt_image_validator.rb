# frozen_string_literal: true

require_relative "base_validators"

module RunwayML
  module Validators
    class PromptImageValidator
      def initialize(image_processor:, array_size:, valid_positions:, only_first_frame: false)
        @image_processor = image_processor
        @array_size = array_size
        @valid_positions = valid_positions
        @only_first_frame = only_first_frame
        @image_uri_validator = ImageUriValidator.new
      end

      def validate(prompt_image, errors)
        if prompt_image.nil?
          errors[:prompt_image] = "is required"
          return
        end

        if prompt_image.is_a?(String)
          image_uri_validator.validate(prompt_image, errors)
        elsif prompt_image.is_a?(Array)
          validate_array_format(prompt_image, errors)
        else
          errors[:prompt_image] = "must be a string or an array"
        end
      end

      private

      attr_reader :image_processor, :array_size, :valid_positions, :only_first_frame, :image_uri_validator

      def validate_array_format(prompt_image, errors)
        if array_size.is_a?(Range)
          unless array_size.include?(prompt_image.length)
            errors[:prompt_image] = "array must contain #{array_size.min} to #{array_size.max} items"
            return
          end
        elsif prompt_image.length != array_size
          errors[:prompt_image] = "array must contain exactly #{array_size} item#{'s' if array_size > 1}"
          return
        end

        validate_array_items(prompt_image, errors)
        validate_array_rules(prompt_image, errors)
      end

      def validate_array_items(prompt_image, errors)
        prompt_image.each_with_index do |item, index|
          unless item.is_a?(Hash)
            errors[:prompt_image] = "array items must be objects with 'uri' and 'position' fields"
            return
          end

          unless item.key?(:uri) || item.key?("uri")
            errors[:prompt_image] = "array item #{index + 1} must have 'uri' field"
          end

          unless item.key?(:position) || item.key?("position")
            errors[:prompt_image] = "array item #{index + 1} must have 'position' field"
          end

          position = item[:position] || item["position"]
          if position && !valid_positions.include?(position)
            errors[:prompt_image] = "position must be one of: #{valid_positions.join(', ')}"
          end

          uri = item[:uri] || item["uri"]
          image_uri_validator.validate(uri, errors) if uri
        end
      end

      def validate_array_rules(prompt_image, errors)
        return if errors[:prompt_image] # Skip if there are already errors

        # Rule: cannot generate with only a last frame (veo3.1 specific)
        if only_first_frame && prompt_image.length == 1
          item = prompt_image.first
          position = item[:position] || item["position"]
          if position == "last"
            errors[:prompt_image] = "cannot generate with only a last frame. Must include a first frame."
          end
        end

        # Rule: with 2 items, ensure one is "first" and one is "last"
        if prompt_image.length == 2 && valid_positions.sort == [ "first", "last" ]
          positions = prompt_image.map { |item| item[:position] || item["position"] }.compact
          unless positions.sort == [ "first", "last" ]
            errors[:prompt_image] = "array with 2 items must have one 'first' and one 'last' position"
          end
        end
      end
    end
  end
end
