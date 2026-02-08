# frozen_string_literal: true

require_relative "errors"
require_relative "validators/speech_to_speech_validator"

module RunwayML
  class SpeechToSpeech
    VALID_MODELS = [ "eleven_multilingual_sts_v2" ].freeze
    VALID_MEDIA_TYPES = [ "audio", "video" ].freeze
    VALID_VOICE_TYPES = [ "runway-preset" ].freeze
    VALID_PRESET_IDS = [
      "Maya", "Arjun", "Serene", "Bernard", "Billy", "Mark", "Clint", "Mabel", "Chad", "Leslie",
      "Eleanor", "Elias", "Elliot", "Grungle", "Brodie", "Sandra", "Kirk", "Kylie", "Lara", "Lisa",
      "Malachi", "Marlene", "Martin", "Miriam", "Monster", "Paula", "Pip", "Rusty", "Ragnar", "Xylar",
      "Maggie", "Jack", "Katie", "Noah", "James", "Rina", "Ella", "Mariah", "Frank", "Claudia",
      "Niki", "Vincent", "Kendrick", "Myrna", "Tom", "Wanda", "Benjamin", "Kiana", "Rachel"
    ].freeze

    def initialize(client:)
      @client = client
    end

    def create(model:, media:, voice:, remove_background_noise: false)
      errors = {}

      unless VALID_MODELS.include?(model)
        errors[:model] = "must be one of: #{VALID_MODELS.join(', ')}"
        raise ValidationError, errors
      end

      validator = Validators::SpeechToSpeechValidator.new
      result = validator.validate(
        media: media,
        voice: voice,
        remove_background_noise: remove_background_noise
      )

      errors = result[:errors]
      raise ValidationError, errors unless errors.empty?

      inputs = build_inputs(media, voice, remove_background_noise)

      response = client.post(
        "speech_to_speech",
        inputs.merge(model: model)
      )

      Task.new(id: response["id"], client: client)
    end

    private

    attr_reader :client

    def build_inputs(media, voice, remove_background_noise)
      {
        media: media,
        voice: voice,
        removeBackgroundNoise: remove_background_noise
      }
    end
  end
end
