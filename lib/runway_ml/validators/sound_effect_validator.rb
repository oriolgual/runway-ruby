# frozen_string_literal: true

require_relative "base_validators"

module RunwayML
  module Validators
    class SoundEffectValidator
      def initialize
        @prompt_text_validator = PromptTextValidator.new(max_length: 3000, required: true)
        @duration_validator = DurationValidator.new(range: 0.5..30)
      end

      def validate(prompt_text:, duration:, loop:)
        errors = {}

        prompt_text_validator.validate(prompt_text, errors)
        duration_validator.validate(duration, errors) unless duration.nil?

        { errors: errors }
      end

      private

      attr_reader :prompt_text_validator, :duration_validator
    end
  end
end
