# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Task do
  describe "#initialize" do
    it "creates a task with an id" do
      task_id = test_uuid
      task = described_class.new(id: task_id)
      expect(task.id).to eq(task_id)
    end
  end

  describe "#retrieve" do
    let(:client) { RunwayML.test_client }

    it "fetches and stores task details" do
      task_id = test_uuid
      task = described_class.new(id: task_id, client: client)
      response = {
        "id" => task_id,
        "status" => "PENDING",
        "createdAt" => "2024-06-27T19:49:32.334Z"
      }

      client.inject_response(:get, "tasks/#{task_id}", response: response)

      task.retrieve

      expect(task.status).to eq("PENDING")
      expect(task.created_at).to eq("2024-06-27T19:49:32.334Z")
      expect(task.data).to eq(response)
      expect(client).to have_been_called_with(
        method: :get,
        path: "tasks/#{task_id}",
        params: nil
      )
    end

    it "stores running status details" do
      task_id = test_uuid
      task = described_class.new(id: task_id, client: client)
      response = {
        "id" => task_id,
        "status" => "RUNNING",
        "createdAt" => "2024-06-27T19:49:32.334Z",
        "progress" => 0.42
      }

      client.inject_response(:get, "tasks/#{task_id}", response: response)

      task.retrieve

      expect(task.status).to eq("RUNNING")
      expect(task.progress).to eq(0.42)
      expect(client).to have_been_called_with(
        method: :get,
        path: "tasks/#{task_id}",
        params: nil
      )
    end

    it "stores failed status details" do
      task_id = test_uuid
      task = described_class.new(id: task_id, client: client)
      response = {
        "id" => task_id,
        "status" => "FAILED",
        "createdAt" => "2024-06-27T19:49:32.334Z",
        "failure" => "Something went wrong",
        "failureCode" => "SOME_ERROR"
      }

      client.inject_response(:get, "tasks/#{task_id}", response: response)

      task.retrieve

      expect(task.status).to eq("FAILED")
      expect(task.failure).to eq("Something went wrong")
      expect(task.failure_code).to eq("SOME_ERROR")
      expect(client).to have_been_called_with(
        method: :get,
        path: "tasks/#{task_id}",
        params: nil
      )
    end

    it "stores succeeded status details" do
      task_id = test_uuid
      task = described_class.new(id: task_id, client: client)
      response = {
        "id" => task_id,
        "status" => "SUCCEEDED",
        "createdAt" => "2024-06-27T19:49:32.334Z",
        "output" => [ "https://example.com/output.mp4" ]
      }

      client.inject_response(:get, "tasks/#{task_id}", response: response)

      task.retrieve

      expect(task.status).to eq("SUCCEEDED")
      expect(task.output).to eq([ "https://example.com/output.mp4" ])
      expect(client).to have_been_called_with(
        method: :get,
        path: "tasks/#{task_id}",
        params: nil
      )
    end

    it "raises an error when no client is provided" do
      task = described_class.new(id: test_uuid)

      expect { task.retrieve }.to raise_error(
        ArgumentError,
        /client is required/
      )
    end
  end

  describe "#delete" do
    let(:client) { RunwayML.test_client }

    it "cancels a task and returns true" do
      task_id = test_uuid
      task = described_class.new(id: task_id, client: client)

      client.inject_response(:delete, "tasks/#{task_id}", response: nil)

      expect(task.delete).to eq(true)
      expect(client).to have_been_called_with(
        method: :delete,
        path: "tasks/#{task_id}",
        params: nil
      )
    end

    it "returns false when task is not found" do
      task_id = test_uuid
      task = described_class.new(id: task_id, client: client)
      error = RunwayML::NotFoundError.new(404, nil, "Not Found", {})

      client.inject_response(:delete, "tasks/#{task_id}", response: error)

      expect(task.delete).to eq(false)
      expect(client).to have_been_called_with(
        method: :delete,
        path: "tasks/#{task_id}",
        params: nil
      )
    end

    it "raises an error when no client is provided" do
      task = described_class.new(id: test_uuid)

      expect { task.delete }.to raise_error(ArgumentError, /client is required/)
    end
  end

  describe "#wait_for_output" do
    it "polls until the task succeeds and updates attributes" do
      task_id = test_uuid
      client = RunwayML.test_client
      task = described_class.new(id: task_id, client: client)
      response_pending = {
        "id" => task_id,
        "status" => "RUNNING",
        "progress" => 0.2
      }
      response_succeeded = {
        "id" => task_id,
        "status" => "SUCCEEDED",
        "output" => [ "https://example.com/output.mp4" ]
      }

      client.inject_response(
        :get,
        "tasks/#{task_id}",
        response: [ response_pending, response_succeeded ]
      )
      allow(task).to receive(:sleep)

      result = task.wait_for_output

      expect(result).to eq(task)
      expect(task.status).to eq("SUCCEEDED")
      expect(task.output).to eq([ "https://example.com/output.mp4" ])
    end

    it "raises a TaskFailedError when the task fails" do
      client = RunwayML.test_client
      task_id = test_uuid
      task = described_class.new(id: task_id, client: client)
      response_failed = {
        "id" => task_id,
        "status" => "FAILED",
        "failure" => "Something went wrong",
        "failureCode" => "SOME_ERROR"
      }

      client.inject_response(
        :get,
        "tasks/#{task_id}",
        response: response_failed
      )
      allow(task).to receive(:sleep)

      expect { task.wait_for_output }.to raise_error(RunwayML::TaskFailedError)
      expect(task.status).to eq("FAILED")
      expect(task.failure).to eq("Something went wrong")
    end

    it "raises a TaskTimeoutError when the task does not finish in time" do
      task_id = test_uuid
      client = RunwayML.test_client
      task = described_class.new(id: task_id, client: client)
      response_pending = { "id" => task_id, "status" => "RUNNING" }

      client.inject_response(
        :get,
        "tasks/#{task_id}",
        response: [ response_pending, response_pending ]
      )
      allow(task).to receive(:sleep)
      allow(Time).to receive(:now).and_return(Time.at(0), Time.at(100))

      expect { task.wait_for_output(timeout: 1) }.to raise_error(
        RunwayML::TaskTimeoutError
      )
      expect(task.status).to eq("RUNNING")
    end
  end

  describe "#==" do
    it "returns true when comparing tasks with the same id" do
      task_id = test_uuid
      task1 = described_class.new(id: task_id)
      task2 = described_class.new(id: task_id)
      expect(task1).to eq(task2)
    end

    it "returns false when comparing tasks with different ids" do
      task1 = described_class.new(id: test_uuid)
      task2 = described_class.new(id: test_uuid)
      expect(task1).not_to eq(task2)
    end

    it "returns false when comparing with non-Task objects" do
      task_id = test_uuid
      task = described_class.new(id: task_id)
      expect(task).not_to eq(task_id)
      expect(task).not_to eq({ id: task_id })
    end
  end

  describe "#to_h" do
    it "returns a hash with the id" do
      task_id = test_uuid
      task = described_class.new(id: task_id)
      expect(task.to_h).to eq({ id: task_id })
    end
  end

  describe "#to_s" do
    it "returns a string representation" do
      task_id = test_uuid
      task = described_class.new(id: task_id)
      expect(task.to_s).to eq("#<RunwayML::Task id=#{task_id}>")
    end
  end

  describe "#inspect" do
    it "returns the same as to_s" do
      task = described_class.new(id: test_uuid)
      expect(task.inspect).to eq(task.to_s)
    end
  end
end
