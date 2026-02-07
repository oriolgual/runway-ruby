# frozen_string_literal: true

module RunwayML
  class Task
    attr_reader :id

    def initialize(id:)
      @id = id
    end

    def ==(other)
      other.is_a?(Task) && other.id == id
    end

    def to_h
      { id: id }
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
  end
end
