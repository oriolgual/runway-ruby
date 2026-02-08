# frozen_string_literal: true

require_relative "base_validators"

module RunwayML
  module Validators
    class SpeechToSpeechValidator
      def validate(media:, voice:, remove_background_noise:)
        errors = {}

        validate_media(media, errors)
        validate_voice(voice, errors)
        validate_remove_background_noise(remove_background_noise, errors)

        { errors: errors }
      end

      private

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

      def validate_voice(voice, errors)
        if voice.nil?
          errors[:voice] = "cannot be empty"
          return
        end

        unless voice.is_a?(Hash)
          errors[:voice] = "must be a hash"
          return
        end

        voice_type = voice[:type]
        preset_id = voice[:presetId]

        unless SpeechToSpeech::VALID_VOICE_TYPES.include?(voice_type)
          errors[:voice] = "type must be one of: #{SpeechToSpeech::VALID_VOICE_TYPES.join(', ')}"
        end

        unless SpeechToSpeech::VALID_PRESET_IDS.include?(preset_id)
          errors[:voice] = "presetId must be one of: #{SpeechToSpeech::VALID_PRESET_IDS.join(', ')}" if errors[:voice].nil?
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
