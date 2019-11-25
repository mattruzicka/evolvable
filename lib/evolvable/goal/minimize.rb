# frozen_string_literal: true

module Evolvable::Goal
  class Minimize
    include Evolvable::Goal

    def value
      @value ||= -Float::INFINITY
    end

    def evaluate(object)
      -object.evolvable_value
    end

    def met?(object)
      object.evolvable_value <= value
    end
  end
end
