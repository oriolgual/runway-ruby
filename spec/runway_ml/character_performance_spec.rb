# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::CharacterPerformance do
  let(:client) { RunwayML.test_client }
  let(:character_performance) { described_class.new(client: client) }

  describe "#create" do
    context "with valid act_two parameters and video character" do
      it "validates and posts to the API" do
        task_id = test_uuid
        expected_params = {
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720"
        }
        client.inject_response(
          :post,
          "character_performance",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          character_performance.create(
            model: "act_two",
            character: {
              type: "video",
              uri: "https://example.com/character.mp4"
            },
            reference: {
              type: "video",
              uri: "https://example.com/reference.mp4"
            },
            ratio: "1280:720"
          )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq(task_id)
        expect(client).to have_been_called_with(
          method: :post,
          path: "character_performance",
          params: expected_params
        )
      end
    end

    context "with valid act_two parameters and image character" do
      it "validates and posts with image character" do
        task_id = test_uuid
        expected_params = {
          model: "act_two",
          character: {
            type: "image",
            uri: "https://example.com/character.jpg"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720"
        }
        client.inject_response(
          :post,
          "character_performance",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          character_performance.create(
            model: "act_two",
            character: {
              type: "image",
              uri: "https://example.com/character.jpg"
            },
            reference: {
              type: "video",
              uri: "https://example.com/reference.mp4"
            },
            ratio: "1280:720"
          )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq(task_id)
        expect(client).to have_been_called_with(
          method: :post,
          path: "character_performance",
          params: expected_params
        )
      end
    end

    context "with optional seed parameter" do
      it "includes seed in the request" do
        task_id = test_uuid
        expected_params = {
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          seed: 12_345
        }
        client.inject_response(
          :post,
          "character_performance",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        character_performance.create(
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          seed: 12_345
        )

        expect(client).to have_been_called_with(
          method: :post,
          path: "character_performance",
          params: expected_params
        )
      end
    end

    context "with body_control parameter" do
      it "includes bodyControl in the request" do
        task_id = test_uuid
        expected_params = {
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          bodyControl: true
        }
        client.inject_response(
          :post,
          "character_performance",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        character_performance.create(
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          body_control: true
        )

        expect(client).to have_been_called_with(
          method: :post,
          path: "character_performance",
          params: expected_params
        )
      end
    end

    context "with expression_intensity parameter" do
      it "includes expressionIntensity in the request" do
        task_id = test_uuid
        expected_params = {
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          expressionIntensity: 4
        }
        client.inject_response(
          :post,
          "character_performance",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        character_performance.create(
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          expression_intensity: 4
        )

        expect(client).to have_been_called_with(
          method: :post,
          path: "character_performance",
          params: expected_params
        )
      end
    end

    context "with content moderation settings" do
      it "includes contentModeration with publicFigureThreshold" do
        task_id = test_uuid
        expected_params = {
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          contentModeration: {
            publicFigureThreshold: "low"
          }
        }
        client.inject_response(
          :post,
          "character_performance",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        character_performance.create(
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          public_figure_threshold: "low"
        )

        expect(client).to have_been_called_with(
          method: :post,
          path: "character_performance",
          params: expected_params
        )
      end
    end

    context "with all optional parameters" do
      it "includes all parameters in the request" do
        task_id = test_uuid
        expected_params = {
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          seed: 42,
          bodyControl: true,
          expressionIntensity: 3,
          contentModeration: {
            publicFigureThreshold: "auto"
          }
        }
        client.inject_response(
          :post,
          "character_performance",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        character_performance.create(
          model: "act_two",
          character: {
            type: "video",
            uri: "https://example.com/character.mp4"
          },
          reference: {
            type: "video",
            uri: "https://example.com/reference.mp4"
          },
          ratio: "1280:720",
          seed: 42,
          body_control: true,
          expression_intensity: 3,
          public_figure_threshold: "auto"
        )

        expect(client).to have_been_called_with(
          method: :post,
          path: "character_performance",
          params: expected_params
        )
      end
    end

    context "with runway:// URIs" do
      it "accepts runway URIs for character and reference" do
        task_id = test_uuid
        expected_params = {
          model: "act_two",
          character: {
            type: "video",
            uri: "runway://abc123def456"
          },
          reference: {
            type: "video",
            uri: "runway://xyz789uvw123"
          },
          ratio: "1280:720"
        }
        client.inject_response(
          :post,
          "character_performance",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        character_performance.create(
          model: "act_two",
          character: {
            type: "video",
            uri: "runway://abc123def456"
          },
          reference: {
            type: "video",
            uri: "runway://xyz789uvw123"
          },
          ratio: "1280:720"
        )

        expect(client).to have_been_called_with(
          method: :post,
          path: "character_performance",
          params: expected_params
        )
      end
    end

    context "with invalid model" do
      it "raises ValidationError" do
        expect {
          character_performance.create(
            model: "invalid_model",
            character: {
              type: "video",
              uri: "https://example.com/character.mp4"
            },
            reference: {
              type: "video",
              uri: "https://example.com/reference.mp4"
            },
            ratio: "1280:720"
          )
        }.to raise_error(RunwayML::ValidationError)
      end
    end

    context "with invalid ratio" do
      it "raises ValidationError" do
        expect {
          character_performance.create(
            model: "act_two",
            character: {
              type: "video",
              uri: "https://example.com/character.mp4"
            },
            reference: {
              type: "video",
              uri: "https://example.com/reference.mp4"
            },
            ratio: "invalid_ratio"
          )
        }.to raise_error(RunwayML::ValidationError) { |error|
          expect(error.message).to include("ratio")
        }
      end
    end

    context "with invalid character type" do
      it "raises ValidationError" do
        expect {
          character_performance.create(
            model: "act_two",
            character: {
              type: "audio",
              uri: "https://example.com/character.mp3"
            },
            reference: {
              type: "video",
              uri: "https://example.com/reference.mp4"
            },
            ratio: "1280:720"
          )
        }.to raise_error(RunwayML::ValidationError) { |error|
          expect(error.message).to include("character")
        }
      end
    end

    context "with reference not being video" do
      it "raises ValidationError" do
        expect {
          character_performance.create(
            model: "act_two",
            character: {
              type: "video",
              uri: "https://example.com/character.mp4"
            },
            reference: {
              type: "image",
              uri: "https://example.com/reference.jpg"
            },
            ratio: "1280:720"
          )
        }.to raise_error(RunwayML::ValidationError) { |error|
          expect(error.message).to include("reference")
        }
      end
    end

    context "with invalid seed" do
      it "raises ValidationError for out of range seed" do
        expect {
          character_performance.create(
            model: "act_two",
            character: {
              type: "video",
              uri: "https://example.com/character.mp4"
            },
            reference: {
              type: "video",
              uri: "https://example.com/reference.mp4"
            },
            ratio: "1280:720",
            seed: 5_000_000_000
          )
        }.to raise_error(RunwayML::ValidationError) { |error|
          expect(error.message).to include("seed")
        }
      end
    end

    context "with invalid expression_intensity" do
      it "raises ValidationError for out of range value" do
        expect {
          character_performance.create(
            model: "act_two",
            character: {
              type: "video",
              uri: "https://example.com/character.mp4"
            },
            reference: {
              type: "video",
              uri: "https://example.com/reference.mp4"
            },
            ratio: "1280:720",
            expression_intensity: 10
          )
        }.to raise_error(RunwayML::ValidationError) { |error|
          expect(error.message).to include("expression_intensity")
        }
      end
    end

    context "with invalid body_control" do
      it "raises ValidationError for non-boolean value" do
        expect {
          character_performance.create(
            model: "act_two",
            character: {
              type: "video",
              uri: "https://example.com/character.mp4"
            },
            reference: {
              type: "video",
              uri: "https://example.com/reference.mp4"
            },
            ratio: "1280:720",
            body_control: "yes"
          )
        }.to raise_error(RunwayML::ValidationError) { |error|
          expect(error.message).to include("body_control")
        }
      end
    end

    context "with invalid public_figure_threshold" do
      it "raises ValidationError for invalid threshold" do
        expect {
          character_performance.create(
            model: "act_two",
            character: {
              type: "video",
              uri: "https://example.com/character.mp4"
            },
            reference: {
              type: "video",
              uri: "https://example.com/reference.mp4"
            },
            ratio: "1280:720",
            public_figure_threshold: "high"
          )
        }.to raise_error(RunwayML::ValidationError) { |error|
          expect(error.message).to include("public_figure_threshold")
        }
      end
    end
  end
end
