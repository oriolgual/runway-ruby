# frozen_string_literal: true

require_relative "validators/base_validators"

module RunwayML
  class Task
    POLL_TIME = 6
    POLL_JITTER = 3

    attr_reader :id, :status, :created_at, :progress, :failure, :failure_code, :output, :data

    def initialize(id:, client: nil, data: nil)
      # Only validate UUID for real clients (not TestClient used in specs)
      validate_task_id(id) if client && !client.is_a?(TestClient)
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

    def wait_for_output(timeout: 60 * 10)
      ensure_client!

      start_time = Time.now.to_f

      loop do
        retrieve

        case status
        when "SUCCEEDED"
          return self
        when "FAILED", "CANCELLED"
          raise TaskFailedError.new(self)
        end

        if !timeout.nil? && (Time.now.to_f - start_time) > timeout
          raise TaskTimeoutError.new(self)
        end

        sleep(POLL_TIME + (rand * POLL_JITTER) - (POLL_JITTER / 2.0))
      end
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

    def validate_task_id(task_id)
      validator = Validators::UUIDValidator.new
      errors = {}
      validator.validate(task_id, errors, field: :id)
      raise ValidationError, errors if errors.any?
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
