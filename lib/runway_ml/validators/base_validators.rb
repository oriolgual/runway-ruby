# frozen_string_literal: true

module RunwayML
  module Validators
    class RatioValidator
      def initialize(valid_ratios:)
        @valid_ratios = valid_ratios
      end

      def validate(ratio, errors)
        unless valid_ratios.include?(ratio)
          errors[:ratio] = "must be one of: #{valid_ratios.join(', ')}"
        end
      end

      private

      attr_reader :valid_ratios
    end

    class PromptTextValidator
      def initialize(max_length:, required: true)
        @max_length = max_length
        @required = required
      end

      def validate(prompt_text, errors)
        if prompt_text.nil? || prompt_text.empty?
          errors[:prompt_text] = "cannot be empty" if required
          return
        end

        utf16_length = prompt_text.encode("UTF-16LE").bytesize / 2
        if utf16_length > max_length
          errors[:prompt_text] = "must be at most #{max_length} characters (UTF-16 code units), got #{utf16_length}"
        end
      end

      private

      attr_reader :max_length, :required
    end

    class DurationValidator
      def initialize(valid_values: nil, range: nil, exact: nil)
        @valid_values = valid_values
        @range = range
        @exact = exact
      end

      def validate(duration, errors)
        return unless duration

        if exact
          unless duration == exact
            errors[:duration] = "must be exactly #{exact}"
          end
        elsif valid_values
          unless valid_values.include?(duration)
            errors[:duration] = "must be one of: #{valid_values.join(', ')}"
          end
        elsif range
          unless range.include?(duration)
            errors[:duration] = "must be between #{range.min} and #{range.max} seconds"
          end
        end
      end

      private

      attr_reader :valid_values, :range, :exact
    end

    class SeedValidator
      def initialize(range:)
        @range = range
      end

      def validate(seed, errors)
        return unless seed

        unless range.include?(seed)
          errors[:seed] = "must be between #{range.min} and #{range.max}"
        end
      end

      private

      attr_reader :range
    end

    class PublicFigureThresholdValidator
      def initialize(valid_thresholds:)
        @valid_thresholds = valid_thresholds
      end

      def validate(public_figure_threshold, errors)
        return unless public_figure_threshold

        unless valid_thresholds.include?(public_figure_threshold)
          errors[:public_figure_threshold] = "must be one of: #{valid_thresholds.join(', ')}"
        end
      end

      private

      attr_reader :valid_thresholds
    end

    class AudioValidator
      def validate(audio, errors)
        return if audio.nil?

        unless [ true, false ].include?(audio)
          errors[:audio] = "must be true or false"
        end
      end
    end

    class ImageUriValidator
      VALID_CONTENT_TYPES = [ "image/jpeg", "image/jpg", "image/png", "image/webp" ].freeze

      def validate(uri, errors, field: :prompt_image)
        return unless uri.is_a?(String)

        if uri.length < 13
          errors[field] = "URI must be at least 13 characters"
          return
        end

        if uri.start_with?("https://")
          validate_https_url(uri, errors, field)
        elsif uri.start_with?("runway://")
          validate_runway_uri(uri, errors, field)
        elsif uri.start_with?("data:image/")
          validate_data_uri(uri, errors, field)
        else
          errors[field] = "must be a valid HTTPS URL, Runway URI (runway://), or data URI (data:image/)"
        end
      end

      private

      def validate_https_url(uri, errors, field)
        if uri.length > 2048
          errors[field] = "HTTPS URL must be at most 2048 characters"
        end
      end

      def validate_runway_uri(uri, errors, field)
        if uri.length > 5000
          errors[field] = "Runway URI must be at most 5000 characters"
        end
      end

      def validate_data_uri(uri, errors, field)
        if uri.length > 5242880
          errors[field] = "Data URI must be at most 5242880 characters"
          return
        end

        content_type_match = uri.match(/^data:(image\/[^;,]+)/)
        return unless content_type_match

        content_type = content_type_match[1]
        return if VALID_CONTENT_TYPES.include?(content_type)

        if content_type == "image/gif"
          errors[field] = "GIF images are not supported. Use JPEG, PNG, or WebP"
        else
          errors[field] = "unsupported image type '#{content_type}'. Must be JPEG (image/jpeg or image/jpg), PNG (image/png), or WebP (image/webp)"
        end
      end
    end
  end
end
