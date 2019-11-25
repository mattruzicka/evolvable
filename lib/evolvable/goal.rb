# frozen_string_literal: true

module Evolvable
  module Goal
    def initialize(value: nil)
      @value = value if value
    end

    attr_accessor :value

    def evaluate(_object)
      raise Errors::NotImplemented, __method__
    end

    def met?(_object)
      raise Errors::NotImplemented, __method__
    end
  end
end
