# frozen_string_literal: true

module Evolvable
  class Goal
    def initialize(value: nil)
      @value = value if value
    end

    attr_accessor :value

    def evaluate(_evolvable)
      raise Errors::UndefinedMethod, "#{self.class.name}##{__method__}"
    end

    def met?(_evolvable)
      raise Errors::UndefinedMethod, "#{self.class.name}##{__method__}"
    end
  end
end
