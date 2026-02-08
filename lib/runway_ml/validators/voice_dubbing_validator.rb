# frozen_string_literal: true

require_relative "base_validators"

module RunwayML
  module Validators
    class VoiceDubbingValidator
      def initialize
        @audio_uri_validator = AudioUriValidator.new
      end

      def validate(audio_uri:, target_lang:, disable_voice_cloning:, drop_background_audio:, num_speakers:)
        errors = {}

        validate_audio_uri(audio_uri, errors)
        validate_target_lang(target_lang, errors)
        validate_disable_voice_cloning(disable_voice_cloning, errors)
        validate_drop_background_audio(drop_background_audio, errors)
        validate_num_speakers(num_speakers, errors)

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

      def validate_target_lang(target_lang, errors)
        if target_lang.nil? || target_lang.empty?
          errors[:target_lang] = "cannot be empty"
          return
        end

        unless VoiceDubbing::VALID_TARGET_LANGS.include?(target_lang)
          errors[:target_lang] = "must be one of: #{VoiceDubbing::VALID_TARGET_LANGS.join(', ')}"
        end
      end

      def validate_disable_voice_cloning(disable_voice_cloning, errors)
        return if disable_voice_cloning.nil?

        unless [ true, false ].include?(disable_voice_cloning)
          errors[:disable_voice_cloning] = "must be a boolean"
        end
      end

      def validate_drop_background_audio(drop_background_audio, errors)
        return if drop_background_audio.nil?

        unless [ true, false ].include?(drop_background_audio)
          errors[:drop_background_audio] = "must be a boolean"
        end
      end

      def validate_num_speakers(num_speakers, errors)
        return if num_speakers.nil?

        unless num_speakers.is_a?(Integer)
          errors[:num_speakers] = "must be an integer"
          return
        end

        if num_speakers < 0 || num_speakers > 9007199254740991
          errors[:num_speakers] = "must be between 0 and 9007199254740991"
        end
      end
    end

    class AudioUriValidator
      VALID_CONTENT_TYPES = [ "audio/mpeg", "audio/mp3", "audio/wav", "audio/flac", "audio/m4a", "audio/aac", "audio/ogg", "audio/webm" ].freeze

      def validate(uri, errors, field: :audio_uri)
        return unless uri.is_a?(String)

        if uri.length < 13
          errors[field] = "URI must be at least 13 characters"
          return
        end

        if uri.start_with?("https://")
          validate_https_url(uri, errors, field)
        elsif uri.start_with?("runway://")
          validate_runway_uri(uri, errors, field)
        elsif uri.start_with?("data:audio/")
          validate_data_uri(uri, errors, field)
        else
          errors[field] = "must be a valid HTTPS URL, Runway URI (runway://), or data URI (data:audio/)"
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
        if uri.length > 16777216
          errors[field] = "Data URI must be at most 16777216 characters"
          return
        end

        content_type_match = uri.match(/^data:(audio\/[^;,]+)/)
        return unless content_type_match

        content_type = content_type_match[1]
        errors[field] = "unsupported audio type '#{content_type}'" unless VALID_CONTENT_TYPES.include?(content_type)
      end
    end
  end
end
