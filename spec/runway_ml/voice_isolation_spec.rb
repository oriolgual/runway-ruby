# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::VoiceIsolation do
  let(:client) { RunwayML.test_client }
  let(:voice_isolation) { described_class.new(client: client) }

  describe "#create" do
    context "with valid parameters" do
      it "validates and posts with https URL" do
        task_id = test_uuid
        expected_params = {
          model: "eleven_voice_isolation",
          audioUri: "https://example.com/audio.mp3"
        }
        client.inject_response(
          :post,
          "voice_isolation",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          voice_isolation.create(
            model: "eleven_voice_isolation",
            audio_uri: "https://example.com/audio.mp3"
          )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq(task_id)
        expect(client).to have_been_called_with(
          method: :post,
          path: "voice_isolation",
          params: expected_params
        )
      end

      it "accepts runway URI" do
        task_id = test_uuid
        expected_params = {
          model: "eleven_voice_isolation",
          audioUri: "runway://audio123"
        }
        client.inject_response(
          :post,
          "voice_isolation",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          voice_isolation.create(
            model: "eleven_voice_isolation",
            audio_uri: "runway://audio123"
          )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq(task_id)
        expect(client).to have_been_called_with(
          method: :post,
          path: "voice_isolation",
          params: expected_params
        )
      end

      it "accepts data URI" do
        task_id = test_uuid
        expected_params = {
          model: "eleven_voice_isolation",
          audioUri: "data:audio/mpeg;base64,abc123"
        }
        client.inject_response(
          :post,
          "voice_isolation",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        result =
          voice_isolation.create(
            model: "eleven_voice_isolation",
            audio_uri: "data:audio/mpeg;base64,abc123"
          )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq(task_id)
        expect(client).to have_been_called_with(
          method: :post,
          path: "voice_isolation",
          params: expected_params
        )
      end

      it "accepts wav audio format" do
        task_id = test_uuid
        expected_params = {
          model: "eleven_voice_isolation",
          audioUri: "https://example.com/audio.wav"
        }
        client.inject_response(
          :post,
          "voice_isolation",
          params: expected_params,
          response: {
            "id" => task_id
          }
        )

        voice_isolation.create(
          model: "eleven_voice_isolation",
          audio_uri: "https://example.com/audio.wav"
        )

        expect(client).to have_been_called_with(
          method: :post,
          path: "voice_isolation",
          params: expected_params
        )
      end
    end

    context "with invalid model" do
      it "raises validation error" do
        expect {
          voice_isolation.create(
            model: "invalid_model",
            audio_uri: "https://example.com/audio.mp3"
          )
        }.to raise_error(RunwayML::ValidationError, /model.*must be one of/)
      end
    end

    context "with invalid audio_uri" do
      it "raises validation error for empty audio_uri" do
        expect {
          voice_isolation.create(model: "eleven_voice_isolation", audio_uri: "")
        }.to raise_error(RunwayML::ValidationError, /audio_uri/)
      end

      it "raises validation error for nil audio_uri" do
        expect {
          voice_isolation.create(
            model: "eleven_voice_isolation",
            audio_uri: nil
          )
        }.to raise_error(RunwayML::ValidationError, /audio_uri/)
      end

      it "raises validation error for invalid URI format" do
        expect {
          voice_isolation.create(
            model: "eleven_voice_isolation",
            audio_uri: "invalid://audio.mp3"
          )
        }.to raise_error(RunwayML::ValidationError, /audio_uri/)
      end

      it "raises validation error for too short URI" do
        expect {
          voice_isolation.create(
            model: "eleven_voice_isolation",
            audio_uri: "https://a"
          )
        }.to raise_error(RunwayML::ValidationError, /audio_uri/)
      end

      it "raises validation error for https URL that's too long" do
        long_url = "https://" + "a" * 2050
        expect {
          voice_isolation.create(
            model: "eleven_voice_isolation",
            audio_uri: long_url
          )
        }.to raise_error(RunwayML::ValidationError, /audio_uri.*2048/)
      end
    end
  end
end
