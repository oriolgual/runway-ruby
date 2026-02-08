# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Task do
  describe "#initialize" do
    it "creates a task with an id" do
      task = described_class.new(id: "test-id-123")
      expect(task.id).to eq("test-id-123")
    end
  end

  describe "#retrieve" do
    let(:client) { RunwayML.test_client }

    it "fetches and stores task details" do
      task = described_class.new(id: "task-123", client: client)
      response = {
        "id" => "task-123",
        "status" => "PENDING",
        "createdAt" => "2024-06-27T19:49:32.334Z"
      }

      client.inject_response(:get, "tasks/task-123", response: response)

      task.retrieve

      expect(task.status).to eq("PENDING")
      expect(task.created_at).to eq("2024-06-27T19:49:32.334Z")
      expect(task.data).to eq(response)
      expect(client).to have_been_called_with(method: :get, path: "tasks/task-123", params: nil)
    end

    it "stores running status details" do
      task = described_class.new(id: "task-123", client: client)
      response = {
        "id" => "task-123",
        "status" => "RUNNING",
        "createdAt" => "2024-06-27T19:49:32.334Z",
        "progress" => 0.42
      }

      client.inject_response(:get, "tasks/task-123", response: response)

      task.retrieve

      expect(task.status).to eq("RUNNING")
      expect(task.progress).to eq(0.42)
      expect(client).to have_been_called_with(method: :get, path: "tasks/task-123", params: nil)
    end

    it "stores failed status details" do
      task = described_class.new(id: "task-123", client: client)
      response = {
        "id" => "task-123",
        "status" => "FAILED",
        "createdAt" => "2024-06-27T19:49:32.334Z",
        "failure" => "Something went wrong",
        "failureCode" => "SOME_ERROR"
      }

      client.inject_response(:get, "tasks/task-123", response: response)

      task.retrieve

      expect(task.status).to eq("FAILED")
      expect(task.failure).to eq("Something went wrong")
      expect(task.failure_code).to eq("SOME_ERROR")
      expect(client).to have_been_called_with(method: :get, path: "tasks/task-123", params: nil)
    end

    it "stores succeeded status details" do
      task = described_class.new(id: "task-123", client: client)
      response = {
        "id" => "task-123",
        "status" => "SUCCEEDED",
        "createdAt" => "2024-06-27T19:49:32.334Z",
        "output" => [ "https://example.com/output.mp4" ]
      }

      client.inject_response(:get, "tasks/task-123", response: response)

      task.retrieve

      expect(task.status).to eq("SUCCEEDED")
      expect(task.output).to eq([ "https://example.com/output.mp4" ])
      expect(client).to have_been_called_with(method: :get, path: "tasks/task-123", params: nil)
    end

    it "raises an error when no client is provided" do
      task = described_class.new(id: "task-123")

      expect { task.retrieve }.to raise_error(ArgumentError, /client is required/)
    end
  end

  describe "#delete" do
    let(:client) { RunwayML.test_client }

    it "cancels a task and returns true" do
      task = described_class.new(id: "task-123", client: client)

      client.inject_response(:delete, "tasks/task-123", response: nil)

      expect(task.delete).to eq(true)
      expect(client).to have_been_called_with(method: :delete, path: "tasks/task-123", params: nil)
    end

    it "returns false when task is not found" do
      task = described_class.new(id: "task-123", client: client)
      error = RunwayML::NotFoundError.new(404, nil, "Not Found", {})

      client.inject_response(:delete, "tasks/task-123", response: error)

      expect(task.delete).to eq(false)
      expect(client).to have_been_called_with(method: :delete, path: "tasks/task-123", params: nil)
    end

    it "raises an error when no client is provided" do
      task = described_class.new(id: "task-123")

      expect { task.delete }.to raise_error(ArgumentError, /client is required/)
    end
  end

  describe "#==" do
    it "returns true when comparing tasks with the same id" do
      task1 = described_class.new(id: "test-id")
      task2 = described_class.new(id: "test-id")
      expect(task1).to eq(task2)
    end

    it "returns false when comparing tasks with different ids" do
      task1 = described_class.new(id: "test-id-1")
      task2 = described_class.new(id: "test-id-2")
      expect(task1).not_to eq(task2)
    end

    it "returns false when comparing with non-Task objects" do
      task = described_class.new(id: "test-id")
      expect(task).not_to eq("test-id")
      expect(task).not_to eq({ id: "test-id" })
    end
  end

  describe "#to_h" do
    it "returns a hash with the id" do
      task = described_class.new(id: "test-id-456")
      expect(task.to_h).to eq({ id: "test-id-456" })
    end
  end

  describe "#to_s" do
    it "returns a string representation" do
      task = described_class.new(id: "test-id-789")
      expect(task.to_s).to eq("#<RunwayML::Task id=test-id-789>")
    end
  end

  describe "#inspect" do
    it "returns the same as to_s" do
      task = described_class.new(id: "test-id-abc")
      expect(task.inspect).to eq(task.to_s)
    end
  end
end
