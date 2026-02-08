# frozen_string_literal: true

require_relative "errors"
require_relative "validators/character_performance_validator"

module RunwayML
  class CharacterPerformance
    VALID_MODELS = [ "act_two" ].freeze

    def initialize(client:)
      @client = client
    end

    def create(model:, character:, reference:, ratio:, seed: nil, body_control: nil, expression_intensity: nil, public_figure_threshold: nil)
      errors = {}

      # Validate model
      unless VALID_MODELS.include?(model)
        errors[:model] = "must be one of: #{VALID_MODELS.join(', ')}"
        raise ValidationError, errors
      end

      validator = Validators::CharacterPerformanceValidator.new
      result = validator.validate(
        character: character,
        reference: reference,
        ratio: ratio,
        seed: seed,
        body_control: body_control,
        expression_intensity: expression_intensity,
        public_figure_threshold: public_figure_threshold
      )

      errors = result[:errors]
      raise ValidationError, errors unless errors.empty?

      inputs = build_inputs(character, reference, ratio, seed, body_control, expression_intensity, public_figure_threshold)

      response = client.post(
        "character_performance",
        inputs.merge(model: model)
      )

      Task.new(id: response["id"], client: client)
    end

    private

    attr_reader :client

    def build_inputs(character, reference, ratio, seed, body_control, expression_intensity, public_figure_threshold)
      inputs = {
        character: character,
        reference: reference,
        ratio: ratio
      }

      inputs[:seed] = seed unless seed.nil?
      inputs[:bodyControl] = body_control unless body_control.nil?
      inputs[:expressionIntensity] = expression_intensity unless expression_intensity.nil?

      unless public_figure_threshold.nil?
        inputs[:contentModeration] = { publicFigureThreshold: public_figure_threshold }
      end

      inputs
    end
  end
end
