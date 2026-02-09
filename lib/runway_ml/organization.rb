# frozen_string_literal: true

require_relative "errors"

module RunwayML
  class Organization
    def initialize(client:)
      @client = client
    end

    def retrieve
      response = client.get("organization")
      OrganizationInfo.new(response)
    end

    def usage(start_date: nil, before_date: nil)
      params = {}
      params[:startDate] = start_date if start_date
      params[:beforeDate] = before_date if before_date

      response = if params.empty?
        client.post("organization/usage", {})
      else
        client.post("organization/usage", params)
      end

      UsageInfo.new(response)
    end

    private

    attr_reader :client
  end

  class OrganizationInfo
    attr_reader :tier, :credit_balance, :usage

    def initialize(data)
      @data = data
      @tier = data["tier"] || {}
      @credit_balance = data["creditBalance"] || 0
      @usage = data["usage"] || {}
    end

    def max_monthly_credit_spend
      tier["maxMonthlyCreditSpend"]
    end

    def tier_models
      tier["models"] || {}
    end

    def usage_models
      usage["models"] || {}
    end

    def to_h
      @data
    end

    def inspect
      "#<RunwayML::OrganizationInfo tier=#{tier.inspect} credit_balance=#{credit_balance}>"
    end
  end

  class UsageInfo
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def models
      data["models"] || {}
    end

    def by_model
      models
    end

    def to_h
      data
    end

    def inspect
      "#<RunwayML::UsageInfo models=#{models.keys.join(', ')}>"
    end
  end
end
