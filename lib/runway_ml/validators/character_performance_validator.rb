# frozen_string_literal: true

require_relative "base_validators"

module RunwayML
  module Validators
    class CharacterPerformanceValidator
      def initialize
        @ratio_validator = RatioValidator.new(
          valid_ratios: [ "1280:720", "720:1280", "960:960", "1104:832", "832:1104", "1584:672" ]
        )
        @seed_validator = SeedValidator.new(range: 0..4294967295)
        @body_control_validator = BodyControlValidator.new
        @expression_intensity_validator = ExpressionIntensityValidator.new(range: 1..5)
        @character_validator = CharacterValidator.new
        @reference_video_validator = ReferenceVideoValidator.new
        @public_figure_threshold_validator = PublicFigureThresholdValidator.new(
          valid_thresholds: [ "auto", "low" ]
        )
      end

      def validate(character:, reference:, ratio:, seed: nil, body_control: nil, expression_intensity: nil, public_figure_threshold: nil)
        errors = {}

        character_validator.validate(character, errors)
        reference_video_validator.validate(reference, errors)
        ratio_validator.validate(ratio, errors)
        seed_validator.validate(seed, errors)
        body_control_validator.validate(body_control, errors)
        expression_intensity_validator.validate(expression_intensity, errors)
        public_figure_threshold_validator.validate(public_figure_threshold, errors)

        { errors: errors }
      end

      private

      attr_reader :ratio_validator, :seed_validator, :body_control_validator, :expression_intensity_validator, :character_validator, :reference_video_validator, :public_figure_threshold_validator
    end
  end
end
