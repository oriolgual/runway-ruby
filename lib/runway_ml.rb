# frozen_string_literal: true

require_relative "runway_ml/version"
require_relative "runway_ml/errors"
require_relative "runway_ml/task"
require_relative "runway_ml/client"
require_relative "runway_ml/image_to_video"

module RunwayML
  def self.client(api_secret: ENV["RUNWAY_API_SECRET"])
    Client.new(api_secret: api_secret)
  end

  def self.image_to_video(api_secret: ENV["RUNWAY_API_SECRET"], **params)
    ImageToVideo.new(client: client(api_secret: api_secret)).create(**params)
  end

  def self.task_retrieve(id, api_secret: ENV["RUNWAY_API_SECRET"])
    Task.new(id: id, client: client(api_secret: api_secret)).retrieve
  end

  def self.task_delete(id, api_secret: ENV["RUNWAY_API_SECRET"])
    Task.new(id: id, client: client(api_secret: api_secret)).delete
  end
end
