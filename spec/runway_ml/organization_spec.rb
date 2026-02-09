# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Organization do
  let(:client) { RunwayML.test_client }
  let(:organization) { described_class.new(client: client) }

  describe "#retrieve" do
    it "fetches organization information" do
      org_data = {
        "tier" => {
          "maxMonthlyCreditSpend" => 1000000,
          "models" => { "gen4_turbo" => { "credits_per_second" => 10 } }
        },
        "creditBalance" => 500000,
        "usage" => {
          "models" => {
            "gen4_turbo" => 50000,
            "veo3.1" => 30000
          }
        }
      }

      client.inject_response(:get, "organization", response: org_data)

      result = organization.retrieve

      expect(result).to be_a(RunwayML::OrganizationInfo)
      expect(result.credit_balance).to eq(500000)
      expect(result.tier).to eq(org_data["tier"])
      expect(result.usage).to eq(org_data["usage"])
      expect(client).to have_been_called_with(method: :get, path: "organization")
    end

    it "handles missing tier field" do
      org_data = {
        "creditBalance" => 250000
      }

      client.inject_response(:get, "organization", response: org_data)

      result = organization.retrieve

      expect(result).to be_a(RunwayML::OrganizationInfo)
      expect(result.credit_balance).to eq(250000)
      expect(result.tier).to eq({})
    end

    it "handles missing usage field" do
      org_data = {
        "creditBalance" => 100000,
        "tier" => {}
      }

      client.inject_response(:get, "organization", response: org_data)

      result = organization.retrieve

      expect(result).to be_a(RunwayML::OrganizationInfo)
      expect(result.usage).to eq({})
    end
  end

  describe "#usage" do
    context "with no parameters" do
      it "fetches all usage data" do
        usage_data = {
          "models" => {
            "gen4_turbo" => [
              { "date" => "2026-02-01", "credits_used" => 10000 },
              { "date" => "2026-02-02", "credits_used" => 15000 }
            ],
            "veo3.1" => [
              { "date" => "2026-02-01", "credits_used" => 5000 }
            ]
          }
        }

        client.inject_response(:post, "organization/usage", params: {}, response: usage_data)

        result = organization.usage

        expect(result).to be_a(RunwayML::UsageInfo)
        expect(result.models).to have_key("gen4_turbo")
        expect(result.models).to have_key("veo3.1")
        expect(client).to have_been_called_with(method: :post, path: "organization/usage", params: {})
      end
    end

    context "with start_date" do
      it "includes startDate in request" do
        usage_data = { "models" => {} }

        client.inject_response(
          :post,
          "organization/usage",
          params: { startDate: "2026-01-01" },
          response: usage_data
        )

        organization.usage(start_date: "2026-01-01")

        expect(client).to have_been_called_with(
          method: :post,
          path: "organization/usage",
          params: { startDate: "2026-01-01" }
        )
      end
    end

    context "with before_date" do
      it "includes beforeDate in request" do
        usage_data = { "models" => {} }

        client.inject_response(
          :post,
          "organization/usage",
          params: { beforeDate: "2026-02-08" },
          response: usage_data
        )

        organization.usage(before_date: "2026-02-08")

        expect(client).to have_been_called_with(
          method: :post,
          path: "organization/usage",
          params: { beforeDate: "2026-02-08" }
        )
      end
    end

    context "with both dates" do
      it "includes both startDate and beforeDate in request" do
        usage_data = { "models" => {} }

        client.inject_response(
          :post,
          "organization/usage",
          params: { startDate: "2026-01-01", beforeDate: "2026-02-08" },
          response: usage_data
        )

        organization.usage(start_date: "2026-01-01", before_date: "2026-02-08")

        expect(client).to have_been_called_with(
          method: :post,
          path: "organization/usage",
          params: { startDate: "2026-01-01", beforeDate: "2026-02-08" }
        )
      end
    end
  end
end

RSpec.describe RunwayML::OrganizationInfo do
  let(:data) do
    {
      "tier" => {
        "maxMonthlyCreditSpend" => 1000000,
        "models" => { "gen4_turbo" => { "credits_per_second" => 10 } }
      },
      "creditBalance" => 500000,
      "usage" => {
        "models" => {
          "gen4_turbo" => 50000,
          "veo3.1" => 30000
        }
      }
    }
  end

  let(:org_info) { described_class.new(data) }

  describe "#initialize" do
    it "stores tier information" do
      expect(org_info.tier).to eq(data["tier"])
    end

    it "stores credit balance" do
      expect(org_info.credit_balance).to eq(500000)
    end

    it "stores usage information" do
      expect(org_info.usage).to eq(data["usage"])
    end
  end

  describe "#max_monthly_credit_spend" do
    it "returns the max monthly credit spend" do
      expect(org_info.max_monthly_credit_spend).to eq(1000000)
    end
  end

  describe "#tier_models" do
    it "returns the models in tier" do
      expect(org_info.tier_models).to eq(data["tier"]["models"])
    end
  end

  describe "#usage_models" do
    it "returns the models in usage" do
      expect(org_info.usage_models).to eq(data["usage"]["models"])
    end
  end

  describe "#to_h" do
    it "returns the data hash" do
      expect(org_info.to_h).to eq(data)
    end
  end

  describe "#inspect" do
    it "returns a string representation" do
      expect(org_info.inspect).to include("OrganizationInfo")
      expect(org_info.inspect).to include("credit_balance=500000")
    end
  end
end

RSpec.describe RunwayML::UsageInfo do
  let(:data) do
    {
      "models" => {
        "gen4_turbo" => [
          { "date" => "2026-02-01", "credits_used" => 10000 },
          { "date" => "2026-02-02", "credits_used" => 15000 }
        ],
        "veo3.1" => [
          { "date" => "2026-02-01", "credits_used" => 5000 }
        ]
      }
    }
  end

  let(:usage_info) { described_class.new(data) }

  describe "#initialize" do
    it "stores usage data" do
      expect(usage_info.data).to eq(data)
    end
  end

  describe "#models" do
    it "returns the models" do
      expect(usage_info.models).to have_key("gen4_turbo")
      expect(usage_info.models).to have_key("veo3.1")
    end
  end

  describe "#by_model" do
    it "returns the models (alias)" do
      expect(usage_info.by_model).to eq(usage_info.models)
    end
  end

  describe "#to_h" do
    it "returns the data hash" do
      expect(usage_info.to_h).to eq(data)
    end
  end

  describe "#inspect" do
    it "returns a string representation" do
      expect(usage_info.inspect).to include("UsageInfo")
      expect(usage_info.inspect).to include("models=")
    end
  end
end
