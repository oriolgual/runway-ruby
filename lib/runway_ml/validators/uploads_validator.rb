# frozen_string_literal: true

module RunwayML
  module Validators
    class UploadsValidator
      def initialize
      end

      def validate(filename:)
        errors = {}

        validate_filename(filename, errors)

        { errors: errors }
      end

      private

      def validate_filename(filename, errors)
        unless filename.is_a?(String)
          errors[:filename] = "must be a string"
          return
        end

        if filename.nil? || filename.empty?
          errors[:filename] = "cannot be empty"
          return
        end

        if filename.length < 3 || filename.length > 255
          errors[:filename] = "must be between 3 and 255 characters"
          return
        end

        # Extract extension
        extension = filename.split(".").last&.downcase
        unless extension && Uploads::SUPPORTED_EXTENSIONS.key?(extension)
          errors[:filename] = "must have a valid extension. Supported: #{Uploads::SUPPORTED_EXTENSIONS.keys.join(', ')}"
          nil
        end
      end
    end
  end
end
