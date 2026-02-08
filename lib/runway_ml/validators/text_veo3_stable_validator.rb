# frozen_string_literal: true

require_relative "base_validators"

module RunwayML
  module Validators
    class TextVeo3StableValidator
      def initialize
        @ratio_validator = RatioValidator.new(
          valid_ratios: [ "1280:720", "720:1280", "1080:1920", "1920:1080" ]
        )
        @prompt_text_validator = PromptTextValidator.new(max_length: 1000, required: true)
        @duration_validator = DurationValidator.new(exact: 8)
      end

      def validate(prompt_text:, ratio:, duration:, audio: nil)
        errors = {}

        ratio_validator.validate(ratio, errors)
        prompt_text_validator.validate(prompt_text, errors)
        duration_validator.validate(duration, errors)

        if !audio.nil?
          errors[:audio] = "is not supported for model veo3"
        end

        { errors: errors }
      end

      private

      attr_reader :ratio_validator, :prompt_text_validator, :duration_validator
    end
  end
end
