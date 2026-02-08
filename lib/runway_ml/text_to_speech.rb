# frozen_string_literal: true

require_relative "errors"
require_relative "validators/text_to_speech_validator"

module RunwayML
  class TextToSpeech
    VALID_MODELS = [ "eleven_multilingual_v2" ].freeze

    def initialize(client:)
      @client = client
    end

    def create(model:, prompt_text:, voice:)
      errors = {}

      unless VALID_MODELS.include?(model)
        errors[:model] = "must be one of: #{VALID_MODELS.join(', ')}"
        raise ValidationError, errors
      end

      validator = Validators::TextToSpeechValidator.new
      result = validator.validate(
        prompt_text: prompt_text,
        voice: voice
      )

      errors = result[:errors]
      raise ValidationError, errors unless errors.empty?

      inputs = build_inputs(prompt_text, voice)

      response = client.post(
        "text_to_speech",
        inputs.merge(model: model)
      )

      Task.new(id: response["id"], client: client)
    end

    private

    attr_reader :client

    def build_inputs(prompt_text, voice)
      {
        promptText: prompt_text,
        voice: voice
      }
    end
  end
end
