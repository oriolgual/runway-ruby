# frozen_string_literal: true

require_relative "errors"
require_relative "validators/voice_isolation_validator"

module RunwayML
  class VoiceIsolation
    VALID_MODELS = [ "eleven_voice_isolation" ].freeze

    def initialize(client:)
      @client = client
    end

    def create(model:, audio_uri:)
      errors = {}

      unless VALID_MODELS.include?(model)
        errors[:model] = "must be one of: #{VALID_MODELS.join(', ')}"
        raise ValidationError, errors
      end

      validator = Validators::VoiceIsolationValidator.new
      result = validator.validate(audio_uri: audio_uri)

      errors = result[:errors]
      raise ValidationError, errors unless errors.empty?

      inputs = build_inputs(audio_uri)

      response = client.post(
        "voice_isolation",
        inputs.merge(model: model)
      )

      Task.new(id: response["id"], client: client)
    end

    private

    attr_reader :client

    def build_inputs(audio_uri)
      {
        audioUri: audio_uri
      }
    end
  end
end
