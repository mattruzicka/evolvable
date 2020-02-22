# frozen_string_literal: true

module Evolvable::Goal
  class Equalize
    include Evolvable::Goal

    def value
      @value ||= 0
    end

    def evaluate(instance)
      -(instance.evolvable_value - value).abs
    end

    def met?(instance)
      instance.evolvable_value == value
    end
  end
end
