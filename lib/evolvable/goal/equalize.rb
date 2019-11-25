# frozen_string_literal: true

module Evolvable::Goal
  class Equalize
    include Evolvable::Goal

    def value
      @value ||= 0
    end

    def evaluate(object)
      -(object.evolvable_value - value).abs
    end

    def met?(object)
      object.evolvable_value == value
    end
  end
end
