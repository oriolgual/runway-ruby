# frozen_string_literal: true

require_relative "base_validators"
require_relative "prompt_image_validator"

module RunwayML
  module Validators
    class Veo3Validator
      def initialize(image_processor:)
        @image_processor = image_processor
        @ratio_validator = RatioValidator.new(
          valid_ratios: [ "1280:720", "720:1280", "1080:1920", "1920:1080" ]
        )
        @prompt_text_validator = PromptTextValidator.new(max_length: 1000, required: true)
        @duration_validator = DurationValidator.new(valid_values: [ 4, 6, 8 ])
        @audio_validator = AudioValidator.new
        @prompt_image_validator = PromptImageValidator.new(
          image_processor: image_processor,
          array_size: 1..2,
          valid_positions: [ "first", "last" ],
          only_first_frame: true
        )
      end

      def validate(prompt_image:, prompt_text:, ratio:, duration:, audio:)
        errors = {}

        ratio_validator.validate(ratio, errors)
        prompt_text_validator.validate(prompt_text, errors)
        duration_validator.validate(duration, errors)
        audio_validator.validate(audio, errors)

        # Process and validate prompt_image
        processed_prompt_image = image_processor.process(prompt_image, errors)
        prompt_image_validator.validate(processed_prompt_image, errors)

        { errors: errors, processed_prompt_image: processed_prompt_image }
      end

      private

      attr_reader :image_processor, :ratio_validator, :prompt_text_validator,
                  :duration_validator, :audio_validator, :prompt_image_validator
    end
  end
end
