# frozen_string_literal: true

require_relative "errors"
require_relative "media_processor"
require_relative "validators/voice_dubbing_validator"

module RunwayML
  class VoiceDubbing
    VALID_MODELS = [ "eleven_voice_dubbing" ].freeze
    VALID_TARGET_LANGS = [
      "en", "hi", "pt", "zh", "es", "fr", "de", "ja", "ar", "ru", "ko", "id", "it", "nl", "tr",
      "pl", "sv", "fil", "ms", "ro", "uk", "el", "cs", "da", "fi", "bg", "hr", "sk", "ta"
    ].freeze

    def initialize(client:)
      @client = client
    end

    def create(model:, audio_uri:, target_lang:, disable_voice_cloning: nil, drop_background_audio: nil, num_speakers: nil, auto_upload: true)
      errors = {}

      unless VALID_MODELS.include?(model)
        errors[:model] = "must be one of: #{VALID_MODELS.join(', ')}"
        raise ValidationError, errors
      end

      # Process audio_uri with auto-upload support
      processed_audio_uri = MediaProcessor.process(
        audio_uri,
        errors,
        client: client,
        auto_upload: auto_upload
      )

      validator = Validators::VoiceDubbingValidator.new
      result = validator.validate(
        audio_uri: processed_audio_uri,
        target_lang: target_lang,
        disable_voice_cloning: disable_voice_cloning,
        drop_background_audio: drop_background_audio,
        num_speakers: num_speakers
      )

      errors = result[:errors]
      raise ValidationError, errors unless errors.empty?

      inputs = build_inputs(processed_audio_uri, target_lang, disable_voice_cloning, drop_background_audio, num_speakers)

      response = client.post(
        "voice_dubbing",
        inputs.merge(model: model)
      )

      Task.new(id: response["id"], client: client)
    end

    private

    attr_reader :client

    def build_inputs(audio_uri, target_lang, disable_voice_cloning, drop_background_audio, num_speakers)
      inputs = {
        audioUri: audio_uri,
        targetLang: target_lang
      }

      inputs[:disableVoiceCloning] = disable_voice_cloning unless disable_voice_cloning.nil?
      inputs[:dropBackgroundAudio] = drop_background_audio unless drop_background_audio.nil?
      inputs[:numSpeakers] = num_speakers unless num_speakers.nil?

      inputs
    end
  end
end
