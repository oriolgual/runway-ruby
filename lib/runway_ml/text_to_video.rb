# frozen_string_literal: true

require_relative "errors"
require_relative "validators/text_veo3_validator"
require_relative "validators/text_veo3_stable_validator"

module RunwayML
  class TextToVideo
    VALID_MODELS = [ "veo3.1", "veo3.1_fast", "veo3" ].freeze

    def initialize(client:)
      @client = client
    end

    def create(model:, prompt_text:, ratio:, duration:, audio: nil)
      errors = {}

      unless VALID_MODELS.include?(model)
        errors[:model] = "must be one of: #{VALID_MODELS.join(', ')}"
        raise ValidationError, errors
      end

      validator = get_validator(model)
      result = validator.validate(**build_validator_params(model, prompt_text, ratio, duration, audio))

      errors = result[:errors]
      raise ValidationError, errors unless errors.empty?

      inputs = build_inputs(model, prompt_text, ratio, duration, audio)

      response = client.post(
        "text_to_video",
        inputs.merge(model: model)
      )

      Task.new(id: response["id"], client: client)
    end

    private

    attr_reader :client

    def get_validator(model)
      case model
      when "veo3.1", "veo3.1_fast"
        Validators::TextVeo3Validator.new
      when "veo3"
        Validators::TextVeo3StableValidator.new
      else
        raise ArgumentError, "No validator configured for model: #{model}"
      end
    end

    def build_validator_params(model, prompt_text, ratio, duration, audio)
      case model
      when "veo3.1", "veo3.1_fast"
        {
          prompt_text: prompt_text,
          ratio: ratio,
          duration: duration,
          audio: audio
        }
      when "veo3"
        {
          prompt_text: prompt_text,
          ratio: ratio,
          duration: duration,
          audio: audio
        }
      else
        {}
      end
    end

    def build_inputs(model, prompt_text, ratio, duration, audio)
      inputs = {
        promptText: prompt_text,
        ratio: ratio,
        duration: duration
      }

      case model
      when "veo3.1", "veo3.1_fast"
        inputs[:audio] = audio unless audio.nil?
      when "veo3"
        # audio not supported for veo3
      end

      inputs
    end
  end
end
