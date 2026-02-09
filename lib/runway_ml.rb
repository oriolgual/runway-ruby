# frozen_string_literal: true

require_relative "runway_ml/version"
require_relative "runway_ml/errors"
require_relative "runway_ml/task"
require_relative "runway_ml/client"
require_relative "runway_ml/image_to_video"
require_relative "runway_ml/text_to_video"
require_relative "runway_ml/character_performance"
require_relative "runway_ml/sound_effect"
require_relative "runway_ml/speech_to_speech"
require_relative "runway_ml/text_to_speech"
require_relative "runway_ml/voice_dubbing"
require_relative "runway_ml/voice_isolation"
require_relative "runway_ml/uploads"
require_relative "runway_ml/organization"

module RunwayML
  class << self
    attr_accessor :client_class
    attr_accessor :test_client
  end

  self.client_class = Client

  def self.client(api_secret: ENV["RUNWAY_API_SECRET"])
    return test_client if test_client

    client_class.new(api_secret: api_secret)
  end

  def self.image_to_video(api_secret: ENV["RUNWAY_API_SECRET"], **params)
    ImageToVideo.new(client: client(api_secret: api_secret)).create(**params)
  end

  def self.text_to_video(api_secret: ENV["RUNWAY_API_SECRET"], **params)
    TextToVideo.new(client: client(api_secret: api_secret)).create(**params)
  end

  def self.character_performance(api_secret: ENV["RUNWAY_API_SECRET"], **params)
    CharacterPerformance.new(client: client(api_secret: api_secret)).create(**params)
  end

  def self.sound_effect(api_secret: ENV["RUNWAY_API_SECRET"], **params)
    SoundEffect.new(client: client(api_secret: api_secret)).create(**params)
  end

  def self.speech_to_speech(api_secret: ENV["RUNWAY_API_SECRET"], **params)
    SpeechToSpeech.new(client: client(api_secret: api_secret)).create(**params)
  end

  def self.text_to_speech(api_secret: ENV["RUNWAY_API_SECRET"], **params)
    TextToSpeech.new(client: client(api_secret: api_secret)).create(**params)
  end

  def self.voice_dubbing(api_secret: ENV["RUNWAY_API_SECRET"], **params)
    VoiceDubbing.new(client: client(api_secret: api_secret)).create(**params)
  end

  def self.voice_isolation(api_secret: ENV["RUNWAY_API_SECRET"], **params)
    VoiceIsolation.new(client: client(api_secret: api_secret)).create(**params)
  end

  def self.uploads(api_secret: ENV["RUNWAY_API_SECRET"])
    Uploads.new(client: client(api_secret: api_secret))
  end

  def self.organization(api_secret: ENV["RUNWAY_API_SECRET"])
    Organization.new(client: client(api_secret: api_secret))
  end

  def self.task_retrieve(id, api_secret: ENV["RUNWAY_API_SECRET"])
    Task.new(id: id, client: client(api_secret: api_secret)).retrieve
  end

  def self.task_delete(id, api_secret: ENV["RUNWAY_API_SECRET"])
    Task.new(id: id, client: client(api_secret: api_secret)).delete
  end
end
