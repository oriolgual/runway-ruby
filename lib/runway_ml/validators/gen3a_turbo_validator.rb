# frozen_string_literal: true

require_relative "base_validators"
require_relative "prompt_image_validator"

module RunwayML
  module Validators
    class Gen3aTurboValidator
      def initialize(image_processor:)
        @image_processor = image_processor
        @ratio_validator = RatioValidator.new(valid_ratios: [ "768:1280", "1280:768" ])
        @prompt_text_validator = PromptTextValidator.new(max_length: 1000, required: true)
        @duration_validator = DurationValidator.new(valid_values: [ 5, 10 ])
        @seed_validator = SeedValidator.new(range: 0..4294967295)
        @public_figure_threshold_validator = PublicFigureThresholdValidator.new(
          valid_thresholds: [ "auto", "low" ]
        )
        @prompt_image_validator = PromptImageValidator.new(
          image_processor: image_processor,
          array_size: 1..2,
          valid_positions: [ "first", "last" ]
        )
      end

      def validate(prompt_image:, prompt_text:, ratio:, duration:, seed:, public_figure_threshold:)
        errors = {}

        ratio_validator.validate(ratio, errors)
        prompt_text_validator.validate(prompt_text, errors)
        duration_validator.validate(duration, errors)
        seed_validator.validate(seed, errors)
        public_figure_threshold_validator.validate(public_figure_threshold, errors)

        # Process and validate prompt_image
        processed_prompt_image = image_processor.process(prompt_image, errors)
        prompt_image_validator.validate(processed_prompt_image, errors)

        { errors: errors, processed_prompt_image: processed_prompt_image }
      end

      private

      attr_reader :image_processor, :ratio_validator, :prompt_text_validator,
                  :duration_validator, :seed_validator, :public_figure_threshold_validator,
                  :prompt_image_validator
    end
  end
end
