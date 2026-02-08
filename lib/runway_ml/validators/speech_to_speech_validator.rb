# frozen_string_literal: true

require_relative "base_validators"
require_relative "voice_validator"

module RunwayML
  module Validators
    class SpeechToSpeechValidator
      def initialize
        @voice_validator = VoiceValidator.new
      end

      def validate(media:, voice:, remove_background_noise:)
        errors = {}

        validate_media(media, errors)
        voice_validator.validate(voice, errors)
        validate_remove_background_noise(remove_background_noise, errors)

        { errors: errors }
      end

      private

      attr_reader :voice_validator

      def validate_media(media, errors)
        if media.nil?
          errors[:media] = "cannot be empty"
          return
        end

        unless media.is_a?(Hash)
          errors[:media] = "must be a hash"
          return
        end

        media_type = media[:type]
        media_uri = media[:uri]

        unless SpeechToSpeech::VALID_MEDIA_TYPES.include?(media_type)
          errors[:media] = "type must be one of: #{SpeechToSpeech::VALID_MEDIA_TYPES.join(', ')}"
        end

        if media_uri.nil? || media_uri.empty?
          errors[:media] = "uri cannot be empty" if errors[:media].nil?
        end
      end

      def validate_remove_background_noise(remove_background_noise, errors)
        unless [ true, false ].include?(remove_background_noise)
          errors[:remove_background_noise] = "must be a boolean"
        end
      end
    end
  end
end
