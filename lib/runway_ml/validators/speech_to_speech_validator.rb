# frozen_string_literal: true

require_relative "base_validators"

module RunwayML
  module Validators
    class SpeechToSpeechValidator
      VALID_MEDIA_TYPES = [ "audio", "video" ].freeze
      VALID_VOICE_TYPES = [ "runway-preset" ].freeze
      VALID_PRESET_IDS = [
        "Maya", "Arjun", "Serene", "Bernard", "Billy", "Mark", "Clint", "Mabel", "Chad", "Leslie",
        "Eleanor", "Elias", "Elliot", "Grungle", "Brodie", "Sandra", "Kirk", "Kylie", "Lara", "Lisa",
        "Malachi", "Marlene", "Martin", "Miriam", "Monster", "Paula", "Pip", "Rusty", "Ragnar", "Xylar",
        "Maggie", "Jack", "Katie", "Noah", "James", "Rina", "Ella", "Mariah", "Frank", "Claudia",
        "Niki", "Vincent", "Kendrick", "Myrna", "Tom", "Wanda", "Benjamin", "Kiana", "Rachel"
      ].freeze

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

        unless VALID_MEDIA_TYPES.include?(media_type)
          errors[:media] = "type must be one of: #{VALID_MEDIA_TYPES.join(', ')}"
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

        unless VALID_VOICE_TYPES.include?(voice_type)
          errors[:voice] = "type must be one of: #{VALID_VOICE_TYPES.join(', ')}"
        end

        unless VALID_PRESET_IDS.include?(preset_id)
          errors[:voice] = "presetId must be one of: #{VALID_PRESET_IDS.join(', ')}" if errors[:voice].nil?
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
