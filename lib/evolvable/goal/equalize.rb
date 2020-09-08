# frozen_string_literal: true

module Evolvable::Goal
  class Equalize
    include Evolvable::Goal

    def value
      @value ||= 0
    end

    def evaluate(instance)
      -(instance.value - value).abs
    end

    def met?(instance)
      instance.value == value
    end
  end
end
