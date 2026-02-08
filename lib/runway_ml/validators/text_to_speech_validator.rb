# frozen_string_literal: true

require_relative "base_validators"
require_relative "voice_validator"

module RunwayML
  module Validators
    class TextToSpeechValidator
      def initialize
        @prompt_text_validator = PromptTextValidator.new(max_length: 1000, required: true)
        @voice_validator = VoiceValidator.new
      end

      def validate(prompt_text:, voice:)
        errors = {}

        prompt_text_validator.validate(prompt_text, errors)
        voice_validator.validate(voice, errors)

        { errors: errors }
      end

      private

      attr_reader :prompt_text_validator, :voice_validator
    end
  end
end
