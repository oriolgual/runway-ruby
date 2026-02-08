# frozen_string_literal: true

require_relative "image_processor"
require_relative "validators/gen4_turbo_validator"
require_relative "validators/veo3_validator"
require_relative "validators/veo3_stable_validator"
require_relative "validators/gen3a_turbo_validator"

module RunwayML
  class ValidationError < RunwayML::Error
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super(format_message)
    end

    private

    def format_message
      "Validation failed:\n" + errors.map { |field, message| "  - #{field}: #{message}" }.join("\n")
    end
  end

  class ImageToVideo
    VALID_MODELS = [ "gen4_turbo", "veo3.1", "gen3a_turbo", "veo3.1_fast", "veo3" ].freeze

    def initialize(client:)
      @client = client
    end

    def create(model:, prompt_image:, prompt_text:, ratio:, duration:, seed: nil, public_figure_threshold: nil, audio: nil)
      errors = {}

      # Validate model
      unless VALID_MODELS.include?(model)
        errors[:model] = "must be one of: #{VALID_MODELS.join(', ')}"
        raise ValidationError, errors
      end

      # Delegate to model-specific validator
      validator = get_validator(model)
      result = validator.validate(
        **build_validator_params(model, prompt_image, prompt_text, ratio, duration, seed, public_figure_threshold, audio)
      )

      errors = result[:errors]
      processed_prompt_image = result[:processed_prompt_image]

      raise ValidationError, errors unless errors.empty?

      inputs = build_inputs(model, processed_prompt_image, prompt_text, ratio, duration, seed, public_figure_threshold, audio)

      response = client.post(
        "image_to_video",
        inputs.merge(model: model)
      )

      Task.new(id: response["id"], client: client)
    end

    private

    attr_reader :client

    def get_validator(model)
      case model
      when "gen4_turbo"
        Validators::Gen4TurboValidator.new(image_processor: ImageProcessor.new)
      when "veo3.1", "veo3.1_fast"
        Validators::Veo3Validator.new(image_processor: ImageProcessor.new)
      when "veo3"
        Validators::Veo3StableValidator.new(image_processor: ImageProcessor.new)
      when "gen3a_turbo"
        Validators::Gen3aTurboValidator.new(image_processor: ImageProcessor.new)
      else
        raise ArgumentError, "No validator configured for model: #{model}"
      end
    end

    def build_validator_params(model, prompt_image, prompt_text, ratio, duration, seed, public_figure_threshold, audio)
      case model
      when "gen4_turbo"
        {
          prompt_image: prompt_image,
          prompt_text: prompt_text,
          ratio: ratio,
          duration: duration,
          seed: seed,
          public_figure_threshold: public_figure_threshold
        }
      when "veo3.1", "veo3.1_fast"
        {
          prompt_image: prompt_image,
          prompt_text: prompt_text,
          ratio: ratio,
          duration: duration,
          audio: audio
        }
      when "veo3"
        {
          prompt_image: prompt_image,
          prompt_text: prompt_text,
          ratio: ratio,
          duration: duration
        }
      when "gen3a_turbo"
        {
          prompt_image: prompt_image,
          prompt_text: prompt_text,
          ratio: ratio,
          duration: duration,
          seed: seed,
          public_figure_threshold: public_figure_threshold
        }
      else
        {}
      end
    end

    def build_inputs(model, processed_prompt_image, prompt_text, ratio, duration, seed, public_figure_threshold, audio)
      inputs = {
        promptImage: processed_prompt_image,
        promptText: prompt_text,
        ratio: ratio,
        duration: duration
      }

      case model
      when "gen4_turbo"
        inputs[:seed] = seed if seed
        if public_figure_threshold
          inputs[:contentModeration] = {
            publicFigureThreshold: public_figure_threshold
          }
        end
      when "veo3.1", "veo3.1_fast"
        inputs[:audio] = audio unless audio.nil?
      when "veo3"
        # No additional parameters for veo3
      when "gen3a_turbo"
        inputs[:seed] = seed if seed
        if public_figure_threshold
          inputs[:contentModeration] = {
            publicFigureThreshold: public_figure_threshold
          }
        end
      end

      inputs
    end
  end
end
