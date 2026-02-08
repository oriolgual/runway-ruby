# frozen_string_literal: true

require_relative "base_validators"

module RunwayML
  module Validators
    class VoiceValidator
      def validate(voice, errors)
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
    end
  end
end
