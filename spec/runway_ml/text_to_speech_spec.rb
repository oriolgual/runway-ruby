# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::TextToSpeech do
  let(:client) { RunwayML.test_client }
  let(:text_to_speech) { described_class.new(client: client) }

  describe "#create" do
    context "with valid parameters" do
      it "validates and posts with all parameters" do
        task_id = test_uuid
        expected_params = {
          model: "eleven_multilingual_v2",
          promptText: "The quick brown fox jumps over the lazy dog",
          voice: {
            type: "runway-preset",
            presetId: "Leslie"
          }
        }
        client.inject_response(
          :post,
          "text_to_speech",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          text_to_speech.create(
            model: "eleven_multilingual_v2",
            prompt_text: "The quick brown fox jumps over the lazy dog",
            voice: {
              type: "runway-preset",
              presetId: "Leslie"
            }
          )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq(task_id)
        expect(client).to have_been_called_with(
          method: :post,
          path: "text_to_speech",
          params: expected_params
        )
      end

      it "accepts minimum length prompt text" do
        task_id = test_uuid
        expected_params = {
          model: "eleven_multilingual_v2",
          promptText: "a",
          voice: {
            type: "runway-preset",
            presetId: "Noah"
          }
        }
        client.inject_response(
          :post,
          "text_to_speech",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          text_to_speech.create(
            model: "eleven_multilingual_v2",
            prompt_text: "a",
            voice: {
              type: "runway-preset",
              presetId: "Noah"
            }
          )

        expect(result.id).to eq(task_id)
      end

      it "accepts maximum length prompt text" do
        task_id = test_uuid
        long_text = "a" * 1000
        expected_params = {
          model: "eleven_multilingual_v2",
          promptText: long_text,
          voice: {
            type: "runway-preset",
            presetId: "Maya"
          }
        }
        client.inject_response(
          :post,
          "text_to_speech",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          text_to_speech.create(
            model: "eleven_multilingual_v2",
            prompt_text: long_text,
            voice: {
              type: "runway-preset",
              presetId: "Maya"
            }
          )

        expect(result.id).to eq(task_id)
      end
    end

    context "with invalid model" do
      it "raises ValidationError" do
        expect {
          text_to_speech.create(
            model: "invalid_model",
            prompt_text: "Hello",
            voice: {
              type: "runway-preset",
              presetId: "Leslie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /model/)
      end
    end

    context "with invalid prompt_text" do
      it "raises ValidationError when prompt_text is empty" do
        expect {
          text_to_speech.create(
            model: "eleven_multilingual_v2",
            prompt_text: "",
            voice: {
              type: "runway-preset",
              presetId: "Leslie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /prompt_text/)
      end

      it "raises ValidationError when prompt_text is nil" do
        expect {
          text_to_speech.create(
            model: "eleven_multilingual_v2",
            prompt_text: nil,
            voice: {
              type: "runway-preset",
              presetId: "Leslie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /prompt_text/)
      end

      it "raises ValidationError when prompt_text exceeds max length" do
        long_text = "a" * 1001
        expect {
          text_to_speech.create(
            model: "eleven_multilingual_v2",
            prompt_text: long_text,
            voice: {
              type: "runway-preset",
              presetId: "Leslie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /prompt_text/)
      end
    end

    context "with invalid voice" do
      it "raises ValidationError when voice is nil" do
        expect {
          text_to_speech.create(
            model: "eleven_multilingual_v2",
            prompt_text: "Hello",
            voice: nil
          )
        }.to raise_error(RunwayML::ValidationError, /voice/)
      end

      it "raises ValidationError with invalid voice type" do
        expect {
          text_to_speech.create(
            model: "eleven_multilingual_v2",
            prompt_text: "Hello",
            voice: {
              type: "invalid",
              presetId: "Leslie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /voice/)
      end

      it "raises ValidationError with invalid preset ID" do
        expect {
          text_to_speech.create(
            model: "eleven_multilingual_v2",
            prompt_text: "Hello",
            voice: {
              type: "runway-preset",
              presetId: "InvalidVoice"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /voice/)
      end
    end

    context "with all valid preset IDs" do
      %w[
        Maya
        Arjun
        Serene
        Bernard
        Billy
        Mark
        Clint
        Mabel
        Chad
        Leslie
        Eleanor
        Elias
        Elliot
        Grungle
        Brodie
        Sandra
        Kirk
        Kylie
        Lara
        Lisa
        Malachi
        Marlene
        Martin
        Miriam
        Monster
        Paula
        Pip
        Rusty
        Ragnar
        Xylar
        Maggie
        Jack
        Katie
        Noah
        James
        Rina
        Ella
        Mariah
        Frank
        Claudia
        Niki
        Vincent
        Kendrick
        Myrna
        Tom
        Wanda
        Benjamin
        Kiana
        Rachel
      ].each do |preset_id|
        it "accepts preset ID #{preset_id}" do
          task_id = test_uuid
          expected_params = {
            model: "eleven_multilingual_v2",
            promptText: "Hello world",
            voice: {
              type: "runway-preset",
              presetId: preset_id
            }
          }
          client.inject_response(
            :post,
            "text_to_speech",
            params: expected_params,
            response: {
              "id" => task_id
            }
          )

          result =
            text_to_speech.create(
              model: "eleven_multilingual_v2",
              prompt_text: "Hello world",
              voice: {
                type: "runway-preset",
                presetId: preset_id
              }
            )

          expect(result.id).to eq(task_id)
        end
      end
    end
  end
end
