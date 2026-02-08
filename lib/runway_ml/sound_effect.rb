# frozen_string_literal: true

require_relative "errors"
require_relative "validators/sound_effect_validator"

module RunwayML
  class SoundEffect
    VALID_MODELS = [ "eleven_text_to_sound_v2" ].freeze

    def initialize(client:)
      @client = client
    end

    def create(model:, prompt_text:, duration: nil, loop: false)
      errors = {}

      unless VALID_MODELS.include?(model)
        errors[:model] = "must be one of: #{VALID_MODELS.join(', ')}"
        raise ValidationError, errors
      end

      validator = Validators::SoundEffectValidator.new
      result = validator.validate(
        prompt_text: prompt_text,
        duration: duration,
        loop: loop
      )

      errors = result[:errors]
      raise ValidationError, errors unless errors.empty?

      inputs = build_inputs(prompt_text, duration, loop)

      response = client.post(
        "sound_effect",
        inputs.merge(model: model)
      )

      Task.new(id: response["id"], client: client)
    end

    private

    attr_reader :client

    def build_inputs(prompt_text, duration, loop_flag)
      inputs = {
        promptText: prompt_text,
        loop: loop_flag
      }

      inputs[:duration] = duration unless duration.nil?

      inputs
    end
  end
end
