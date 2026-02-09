# frozen_string_literal: true

require_relative "errors"
require_relative "media_processor"
require_relative "validators/character_performance_validator"

module RunwayML
  class CharacterPerformance
    VALID_MODELS = [ "act_two" ].freeze

    def initialize(client:)
      @client = client
    end

    def create(model:, character:, reference:, ratio:, seed: nil, body_control: nil, expression_intensity: nil, public_figure_threshold: nil, auto_upload: true)
      errors = {}

      # Validate model
      unless VALID_MODELS.include?(model)
        errors[:model] = "must be one of: #{VALID_MODELS.join(', ')}"
        raise ValidationError, errors
      end

      # Process character and reference with auto-upload support
      # They can be hashes with 'uri' keys containing file paths
      processed_character = if character.is_a?(Hash) && character[:uri]
        processed_uri = MediaProcessor.process(
          character[:uri],
          errors,
          client: client,
          auto_upload: auto_upload
        )
        character.dup.tap { |h| h[:uri] = processed_uri }
      else
        MediaProcessor.process(
          character,
          errors,
          client: client,
          auto_upload: auto_upload
        )
      end

      processed_reference = if reference.is_a?(Hash) && reference[:uri]
        processed_uri = MediaProcessor.process(
          reference[:uri],
          errors,
          client: client,
          auto_upload: auto_upload
        )
        reference.dup.tap { |h| h[:uri] = processed_uri }
      else
        MediaProcessor.process(
          reference,
          errors,
          client: client,
          auto_upload: auto_upload
        )
      end

      validator = Validators::CharacterPerformanceValidator.new
      result = validator.validate(
        character: processed_character,
        reference: processed_reference,
        ratio: ratio,
        seed: seed,
        body_control: body_control,
        expression_intensity: expression_intensity,
        public_figure_threshold: public_figure_threshold
      )

      errors = result[:errors]
      raise ValidationError, errors unless errors.empty?

      inputs = build_inputs(processed_character, processed_reference, ratio, seed, body_control, expression_intensity, public_figure_threshold)

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
