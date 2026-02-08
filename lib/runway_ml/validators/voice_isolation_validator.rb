# frozen_string_literal: true

require_relative "base_validators"
require_relative "voice_dubbing_validator"

module RunwayML
  module Validators
    class VoiceIsolationValidator
      def initialize
        @audio_uri_validator = AudioUriValidator.new
      end

      def validate(audio_uri:)
        errors = {}

        validate_audio_uri(audio_uri, errors)

        { errors: errors }
      end

      private

      attr_reader :audio_uri_validator

      def validate_audio_uri(audio_uri, errors)
        if audio_uri.nil? || (audio_uri.is_a?(String) && audio_uri.empty?)
          errors[:audio_uri] = "cannot be empty"
          return
        end

        audio_uri_validator.validate(audio_uri, errors, field: :audio_uri)
      end
    end
  end
end
