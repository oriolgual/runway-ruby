# frozen_string_literal: true

require "spec_helper"
require "stringio"
require "tempfile"
require "base64"

RSpec.describe "Auto-upload integration" do
  let(:client) { RunwayML.test_client }

  describe "VoiceDubbing with auto-upload" do
    it "auto-uploads local file and uses runway URI" do
      task_id = test_uuid
      temp_file = Tempfile.new(%w[test .mp3])
      temp_file.write("fake audio data")
      temp_file.close

      # Mock upload response
      client.inject_response(
        :post,
        "uploads",
        params: {
          filename: File.basename(temp_file.path),
          type: "ephemeral"
        },
        response: {
          "uploadUrl" => "https://example.com/upload",
          "fields" => {},
          "runwayUri" => "runway://uploads/dubbed-audio"
        }
      )

      # Mock the actual voice dubbing task creation with the uploaded URI
      expected_params = {
        model: "eleven_voice_dubbing",
        audioUri: "runway://uploads/dubbed-audio",
        targetLang: "es"
      }

      client.inject_response(
        :post,
        "voice_dubbing",
        params: expected_params,
        response: {
          "id" => task_id
        }
      )

      voice_dubbing = RunwayML::VoiceDubbing.new(client: client)
      result =
        voice_dubbing.create(
          model: "eleven_voice_dubbing",
          audio_uri: temp_file.path,
          target_lang: "es",
          auto_upload: true
        )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq(task_id)

      temp_file.unlink
    end

    it "skips upload when auto_upload is false" do
      task_id = test_uuid
      temp_file = Tempfile.new(%w[test .mp3])
      temp_file.write("fake audio data")
      temp_file.close

      # Should convert to data URI and call voice dubbing without uploading
      expected_params = {
        model: "eleven_voice_dubbing",
        audioUri: %r{^data:audio/mpeg;base64,}, # Should be a data URI
        targetLang: "fr"
      }

      # We'll manually construct the expected audio URI for the mock
      expected_audio_uri =
        "data:audio/mpeg;base64,#{Base64.strict_encode64("fake audio data")}"

      client.inject_response(
        :post,
        "voice_dubbing",
        params: {
          model: "eleven_voice_dubbing",
          audioUri: expected_audio_uri,
          targetLang: "fr"
        },
        response: {
          "id" => task_id
        }
      )

      voice_dubbing = RunwayML::VoiceDubbing.new(client: client)
      result =
        voice_dubbing.create(
          model: "eleven_voice_dubbing",
          audio_uri: temp_file.path,
          target_lang: "fr",
          auto_upload: false
        )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq(task_id)

      temp_file.unlink
    end
  end

  describe "VoiceIsolation with auto-upload" do
    it "auto-uploads StringIO and uses runway URI" do
      task_id = test_uuid
      io = StringIO.new("fake audio data")

      # Mock upload response - note the .mp3 extension
      client.inject_response(
        :post,
        "uploads",
        params: {
          filename: "upload.mp3",
          type: "ephemeral"
        },
        response: {
          "uploadUrl" => "https://example.com/upload",
          "fields" => {},
          "runwayUri" => "runway://uploads/isolated-audio"
        }
      )

      # Mock the actual voice isolation task creation
      expected_params = {
        model: "eleven_voice_isolation",
        audioUri: "runway://uploads/isolated-audio"
      }

      client.inject_response(
        :post,
        "voice_isolation",
        params: expected_params,
        response: {
          "id" => task_id
        }
      )

      voice_isolation = RunwayML::VoiceIsolation.new(client: client)
      result =
        voice_isolation.create(
          model: "eleven_voice_isolation",
          audio_uri: io,
          auto_upload: true
        )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq(task_id)
    end
  end

  describe "SpeechToSpeech with auto-upload" do
    it "auto-uploads media in hash" do
      task_id = test_uuid
      temp_file = Tempfile.new(%w[test .mp4])
      temp_file.write("fake video data")
      temp_file.close

      # Mock upload response
      client.inject_response(
        :post,
        "uploads",
        params: {
          filename: File.basename(temp_file.path),
          type: "ephemeral"
        },
        response: {
          "uploadUrl" => "https://example.com/upload",
          "fields" => {},
          "runwayUri" => "runway://uploads/speech-video"
        }
      )

      # Mock the actual speech-to-speech task creation
      expected_params = {
        model: "eleven_multilingual_sts_v2",
        media: {
          type: "video",
          uri: "runway://uploads/speech-video"
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

      speech_to_speech = RunwayML::SpeechToSpeech.new(client: client)
      result =
        speech_to_speech.create(
          model: "eleven_multilingual_sts_v2",
          media: {
            type: "video",
            uri: temp_file.path
          },
          voice: {
            type: "runway-preset",
            presetId: "Noah"
          },
          auto_upload: true
        )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq(task_id)

      temp_file.unlink
    end
  end

  describe "Image and Video Support" do
    it "supports auto-upload for image files" do
      task_id = test_uuid
      temp_file = Tempfile.new(%w[test .jpg])
      temp_file.write("fake image data")
      temp_file.close

      # Mock upload response for image
      client.inject_response(
        :post,
        "uploads",
        params: {
          filename: File.basename(temp_file.path),
          type: "ephemeral"
        },
        response: {
          "uploadUrl" => "https://example.com/upload",
          "fields" => {},
          "runwayUri" => "runway://uploads/image123"
        }
      )

      # Mock the actual API call (using voice_dubbing for testing as an example audio method that accepts URIs)
      client.inject_response(
        :post,
        "voice_dubbing",
        params: {
          model: "eleven_voice_dubbing",
          audioUri: "runway://uploads/image123",
          targetLang: "es"
        },
        response: {
          "id" => task_id
        }
      )

      voice_dubbing = RunwayML::VoiceDubbing.new(client: client)
      result =
        voice_dubbing.create(
          model: "eleven_voice_dubbing",
          audio_uri: temp_file.path,
          target_lang: "es",
          auto_upload: true
        )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq(task_id)

      temp_file.unlink
    end

    it "supports auto-upload for video files" do
      task_id = test_uuid
      temp_file = Tempfile.new(%w[test .mp4])
      temp_file.write("fake video data")
      temp_file.close

      # Mock upload response for video
      client.inject_response(
        :post,
        "uploads",
        params: {
          filename: File.basename(temp_file.path),
          type: "ephemeral"
        },
        response: {
          "uploadUrl" => "https://example.com/upload",
          "fields" => {},
          "runwayUri" => "runway://uploads/video123"
        }
      )

      # Mock the actual API call
      client.inject_response(
        :post,
        "speech_to_speech",
        params: {
          model: "eleven_multilingual_sts_v2",
          media: {
            type: "video",
            uri: "runway://uploads/video123"
          },
          voice: {
            type: "runway-preset",
            presetId: "James"
          },
          removeBackgroundNoise: false
        },
        response: {
          "id" => task_id
        }
      )

      speech_to_speech = RunwayML::SpeechToSpeech.new(client: client)
      result =
        speech_to_speech.create(
          model: "eleven_multilingual_sts_v2",
          media: {
            type: "video",
            uri: temp_file.path
          },
          voice: {
            type: "runway-preset",
            presetId: "James"
          },
          auto_upload: true
        )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq(task_id)

      temp_file.unlink
    end

    it "auto-uploads images in ImageToVideo.create" do
      task_id = test_uuid
      temp_file = Tempfile.new(%w[test .png])
      temp_file.write("fake image data")
      temp_file.close

      # Mock upload response
      client.inject_response(
        :post,
        "uploads",
        params: {
          filename: File.basename(temp_file.path),
          type: "ephemeral"
        },
        response: {
          "uploadUrl" => "https://example.com/upload",
          "fields" => {},
          "runwayUri" => "runway://uploads/prompt-image"
        }
      )

      # Mock the actual image-to-video task creation
      client.inject_response(
        :post,
        "image_to_video",
        params: {
          model: "gen4_turbo",
          promptImage: "runway://uploads/prompt-image",
          promptText: "A timelapse",
          ratio: "1280:720",
          duration: 5
        },
        response: {
          "id" => task_id
        }
      )

      image_to_video = RunwayML::ImageToVideo.new(client: client)
      result =
        image_to_video.create(
          model: "gen4_turbo",
          prompt_image: temp_file.path,
          prompt_text: "A timelapse",
          ratio: "1280:720",
          duration: 5,
          auto_upload: true
        )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq(task_id)

      temp_file.unlink
    end

    it "auto-uploads images in CharacterPerformance.create" do
      task_id = test_uuid
      character_file = Tempfile.new(%w[character .jpg])
      character_file.write("fake character image")
      character_file.close

      reference_file = Tempfile.new(%w[reference .mp4])
      reference_file.write("fake reference video")
      reference_file.close

      # Mock upload responses
      client.inject_response(
        :post,
        "uploads",
        params: {
          filename: File.basename(character_file.path),
          type: "ephemeral"
        },
        response: {
          "uploadUrl" => "https://example.com/upload",
          "fields" => {},
          "runwayUri" => "runway://uploads/character"
        }
      )

      client.inject_response(
        :post,
        "uploads",
        params: {
          filename: File.basename(reference_file.path),
          type: "ephemeral"
        },
        response: {
          "uploadUrl" => "https://example.com/upload",
          "fields" => {},
          "runwayUri" => "runway://uploads/reference"
        }
      )

      # Mock the actual character performance task creation
      client.inject_response(
        :post,
        "character_performance",
        params: {
          model: "act_two",
          character: {
            type: "image",
            uri: "runway://uploads/character"
          },
          reference: {
            type: "video",
            uri: "runway://uploads/reference"
          },
          ratio: "1280:720"
        },
        response: {
          "id" => task_id
        }
      )

      character_performance = RunwayML::CharacterPerformance.new(client: client)
      result =
        character_performance.create(
          model: "act_two",
          character: {
            type: "image",
            uri: character_file.path
          },
          reference: {
            type: "video",
            uri: reference_file.path
          },
          ratio: "1280:720",
          auto_upload: true
        )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq(task_id)

      character_file.unlink
      reference_file.unlink
    end
  end
end
