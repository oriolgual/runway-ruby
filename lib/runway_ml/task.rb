# frozen_string_literal: true

module RunwayML
  class Task
    attr_reader :id, :status, :created_at, :progress, :failure, :failure_code, :output, :data

    def initialize(id:, client: nil, data: nil)
      @id = id
      @client = client
      apply_data(data) if data
    end

    def retrieve
      ensure_client!

      response = client.get("tasks/#{id}")
      apply_data(response)
      self
    end

    def delete
      ensure_client!

      client.delete("tasks/#{id}")
      true
    rescue NotFoundError
      false
    end

    def ==(other)
      other.is_a?(Task) && other.id == id
    end

    def to_h
      hash = { id: id }
      hash[:status] = status if status
      hash[:created_at] = created_at if created_at
      hash[:progress] = progress if progress
      hash[:failure] = failure if failure
      hash[:failure_code] = failure_code if failure_code
      hash[:output] = output if output
      hash
    end

    def to_json
      to_h.to_json
    end

    def to_s
      "#<RunwayML::Task id=#{id}>"
    end

    def inspect
      to_s
    end

    private

    attr_reader :client

    def ensure_client!
      return if client

      raise ArgumentError, "Task client is required to retrieve or delete tasks"
    end

    def apply_data(payload)
      return unless payload.is_a?(Hash)

      @data = payload
      @status = payload["status"] || payload[:status]
      @created_at = payload["createdAt"] || payload[:created_at]
      @progress = payload["progress"] || payload[:progress]
      @failure = payload["failure"] || payload[:failure]
      @failure_code = payload["failureCode"] || payload[:failure_code]
      @output = payload["output"] || payload[:output]
    end
  end
end
