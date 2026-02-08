# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::VoiceDubbing do
  let(:client) { RunwayML.test_client }
  let(:voice_dubbing) { described_class.new(client: client) }

  describe "#create" do
    context "with valid parameters" do
      it "validates and posts with all parameters" do
        expected_params = {
          model: "eleven_voice_dubbing",
          audioUri: "https://example.com/audio.mp3",
          targetLang: "es",
          disableVoiceCloning: true,
          dropBackgroundAudio: true,
          numSpeakers: 2
        }
        client.inject_response(:post, "voice_dubbing", params: expected_params, response: { "id" => "task-dubbing-123" })

        result = voice_dubbing.create(
          model: "eleven_voice_dubbing",
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "es",
          disable_voice_cloning: true,
          drop_background_audio: true,
          num_speakers: 2
        )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq("task-dubbing-123")
        expect(client).to have_been_called_with(method: :post, path: "voice_dubbing", params: expected_params)
      end

      it "omits optional parameters when not provided" do
        expected_params = {
          model: "eleven_voice_dubbing",
          audioUri: "https://example.com/audio.mp3",
          targetLang: "fr"
        }
        client.inject_response(:post, "voice_dubbing", params: expected_params, response: { "id" => "task-dubbing-124" })

        result = voice_dubbing.create(
          model: "eleven_voice_dubbing",
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "fr"
        )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq("task-dubbing-124")
        expect(client).to have_been_called_with(method: :post, path: "voice_dubbing", params: expected_params)
      end

      it "accepts all valid target languages" do
        RunwayML::VoiceDubbing::VALID_TARGET_LANGS.each do |lang|
          expected_params = {
            model: "eleven_voice_dubbing",
            audioUri: "https://example.com/audio.mp3",
            targetLang: lang
          }
          client.inject_response(:post, "voice_dubbing", params: expected_params, response: { "id" => "task-dubbing-lang" })

          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "https://example.com/audio.mp3",
            target_lang: lang
          )

          expect(client).to have_been_called_with(method: :post, path: "voice_dubbing", params: expected_params)
        end
      end

      it "accepts runway URI" do
        expected_params = {
          model: "eleven_voice_dubbing",
          audioUri: "runway://audio123",
          targetLang: "de"
        }
        client.inject_response(:post, "voice_dubbing", params: expected_params, response: { "id" => "task-dubbing-125" })

        voice_dubbing.create(
          model: "eleven_voice_dubbing",
          audio_uri: "runway://audio123",
          target_lang: "de"
        )

        expect(client).to have_been_called_with(method: :post, path: "voice_dubbing", params: expected_params)
      end

      it "accepts data URI" do
        expected_params = {
          model: "eleven_voice_dubbing",
          audioUri: "data:audio/mpeg;base64,abc123",
          targetLang: "ja"
        }
        client.inject_response(:post, "voice_dubbing", params: expected_params, response: { "id" => "task-dubbing-126" })

        voice_dubbing.create(
          model: "eleven_voice_dubbing",
          audio_uri: "data:audio/mpeg;base64,abc123",
          target_lang: "ja"
        )

        expect(client).to have_been_called_with(method: :post, path: "voice_dubbing", params: expected_params)
      end
    end

    context "with invalid model" do
      it "raises validation error" do
        expect {
          voice_dubbing.create(
            model: "invalid_model",
            audio_uri: "https://example.com/audio.mp3",
            target_lang: "es"
          )
        }.to raise_error(RunwayML::ValidationError, /model.*must be one of/)
      end
    end

    context "with invalid target_lang" do
      it "raises validation error for invalid language" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "https://example.com/audio.mp3",
            target_lang: "invalid"
          )
        }.to raise_error(RunwayML::ValidationError, /target_lang/)
      end

      it "raises validation error for empty language" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "https://example.com/audio.mp3",
            target_lang: ""
          )
        }.to raise_error(RunwayML::ValidationError, /target_lang/)
      end
    end

    context "with invalid audio_uri" do
      it "raises validation error for empty audio_uri" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "",
            target_lang: "es"
          )
        }.to raise_error(RunwayML::ValidationError, /audio_uri/)
      end

      it "raises validation error for nil audio_uri" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: nil,
            target_lang: "es"
          )
        }.to raise_error(RunwayML::ValidationError, /audio_uri/)
      end

      it "raises validation error for invalid URI format" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "invalid://audio.mp3",
            target_lang: "es"
          )
        }.to raise_error(RunwayML::ValidationError, /audio_uri/)
      end

      it "raises validation error for too short URI" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "https://a",
            target_lang: "es"
          )
        }.to raise_error(RunwayML::ValidationError, /audio_uri/)
      end
    end

    context "with invalid optional parameters" do
      it "raises validation error for non-boolean disable_voice_cloning" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "https://example.com/audio.mp3",
            target_lang: "es",
            disable_voice_cloning: "yes"
          )
        }.to raise_error(RunwayML::ValidationError, /disable_voice_cloning/)
      end

      it "raises validation error for non-boolean drop_background_audio" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "https://example.com/audio.mp3",
            target_lang: "es",
            drop_background_audio: "yes"
          )
        }.to raise_error(RunwayML::ValidationError, /drop_background_audio/)
      end

      it "raises validation error for non-integer num_speakers" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "https://example.com/audio.mp3",
            target_lang: "es",
            num_speakers: "two"
          )
        }.to raise_error(RunwayML::ValidationError, /num_speakers/)
      end

      it "raises validation error for negative num_speakers" do
        expect {
          voice_dubbing.create(
            model: "eleven_voice_dubbing",
            audio_uri: "https://example.com/audio.mp3",
            target_lang: "es",
            num_speakers: -1
          )
        }.to raise_error(RunwayML::ValidationError, /num_speakers/)
      end
    end
  end
end
