# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Task do
  describe "#initialize" do
    it "creates a task with an id" do
      task = described_class.new(id: "test-id-123")
      expect(task.id).to eq("test-id-123")
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
