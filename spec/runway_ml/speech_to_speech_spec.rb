# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::SpeechToSpeech do
  let(:client) { RunwayML.test_client }
  let(:speech_to_speech) { described_class.new(client: client) }

  describe "#create" do
    context "with valid audio parameters" do
      it "validates and posts with audio media" do
        task_id = test_uuid
        expected_params = {
          model: "eleven_multilingual_sts_v2",
          media: {
            type: "audio",
            uri: "https://example.com/audio.mp3"
          },
          voice: {
            type: "runway-preset",
            presetId: "Maggie"
          },
          removeBackgroundNoise: false
        }
        client.inject_response(
          :post,
          "speech_to_speech",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          speech_to_speech.create(
            model: "eleven_multilingual_sts_v2",
            media: {
              type: "audio",
              uri: "https://example.com/audio.mp3"
            },
            voice: {
              type: "runway-preset",
              presetId: "Maggie"
            }
          )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq(task_id)
        expect(client).to have_been_called_with(
          method: :post,
          path: "speech_to_speech",
          params: expected_params
        )
      end

      it "accepts remove_background_noise parameter" do
        task_id = test_uuid
        expected_params = {
          model: "eleven_multilingual_sts_v2",
          media: {
            type: "audio",
            uri: "https://example.com/audio.mp3"
          },
          voice: {
            type: "runway-preset",
            presetId: "Maya"
          },
          removeBackgroundNoise: true
        }
        client.inject_response(
          :post,
          "speech_to_speech",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          speech_to_speech.create(
            model: "eleven_multilingual_sts_v2",
            media: {
              type: "audio",
              uri: "https://example.com/audio.mp3"
            },
            voice: {
              type: "runway-preset",
              presetId: "Maya"
            },
            remove_background_noise: true
          )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq(task_id)
        expect(client).to have_been_called_with(
          method: :post,
          path: "speech_to_speech",
          params: expected_params
        )
      end
    end

    context "with valid video parameters" do
      it "validates and posts with video media" do
        task_id = test_uuid
        expected_params = {
          model: "eleven_multilingual_sts_v2",
          media: {
            type: "video",
            uri: "https://example.com/video.mp4"
          },
          voice: {
            type: "runway-preset",
            presetId: "Noah"
          },
          removeBackgroundNoise: false
        }
        client.inject_response(
          :post,
          "speech_to_speech",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          speech_to_speech.create(
            model: "eleven_multilingual_sts_v2",
            media: {
              type: "video",
              uri: "https://example.com/video.mp4"
            },
            voice: {
              type: "runway-preset",
              presetId: "Noah"
            }
          )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq(task_id)
        expect(client).to have_been_called_with(
          method: :post,
          path: "speech_to_speech",
          params: expected_params
        )
      end
    end

    context "with invalid model" do
      it "raises ValidationError" do
        expect {
          speech_to_speech.create(
            model: "invalid_model",
            media: {
              type: "audio",
              uri: "https://example.com/audio.mp3"
            },
            voice: {
              type: "runway-preset",
              presetId: "Maggie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /model/)
      end
    end

    context "with invalid media" do
      it "raises ValidationError when media is nil" do
        expect {
          speech_to_speech.create(
            model: "eleven_multilingual_sts_v2",
            media: nil,
            voice: {
              type: "runway-preset",
              presetId: "Maggie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /media/)
      end

      it "raises ValidationError with invalid media type" do
        expect {
          speech_to_speech.create(
            model: "eleven_multilingual_sts_v2",
            media: {
              type: "invalid",
              uri: "https://example.com/audio.mp3"
            },
            voice: {
              type: "runway-preset",
              presetId: "Maggie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /media/)
      end

      it "raises ValidationError with empty media uri" do
        expect {
          speech_to_speech.create(
            model: "eleven_multilingual_sts_v2",
            media: {
              type: "audio",
              uri: ""
            },
            voice: {
              type: "runway-preset",
              presetId: "Maggie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /media/)
      end
    end

    context "with invalid voice" do
      it "raises ValidationError when voice is nil" do
        expect {
          speech_to_speech.create(
            model: "eleven_multilingual_sts_v2",
            media: {
              type: "audio",
              uri: "https://example.com/audio.mp3"
            },
            voice: nil
          )
        }.to raise_error(RunwayML::ValidationError, /voice/)
      end

      it "raises ValidationError with invalid voice type" do
        expect {
          speech_to_speech.create(
            model: "eleven_multilingual_sts_v2",
            media: {
              type: "audio",
              uri: "https://example.com/audio.mp3"
            },
            voice: {
              type: "invalid",
              presetId: "Maggie"
            }
          )
        }.to raise_error(RunwayML::ValidationError, /voice/)
      end

      it "raises ValidationError with invalid preset ID" do
        expect {
          speech_to_speech.create(
            model: "eleven_multilingual_sts_v2",
            media: {
              type: "audio",
              uri: "https://example.com/audio.mp3"
            },
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
            model: "eleven_multilingual_sts_v2",
            media: {
              type: "audio",
              uri: "https://example.com/audio.mp3"
            },
            voice: {
              type: "runway-preset",
              presetId: preset_id
            },
            removeBackgroundNoise: false
          }
          client.inject_response(
            :post,
            "speech_to_speech",
            params: expected_params,
            response: {
              "id" => task_id
            }
          )

          result =
            speech_to_speech.create(
              model: "eleven_multilingual_sts_v2",
              media: {
                type: "audio",
                uri: "https://example.com/audio.mp3"
              },
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
