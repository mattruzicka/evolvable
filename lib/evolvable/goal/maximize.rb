# frozen_string_literal: true

module Evolvable::Goal
  class Maximize
    include Evolvable::Goal

    def value
      @value ||= Float::INFINITY
    end

    def evaluate(instance)
      instance.value
    end

    def met?(instance)
      instance.value >= value
    end
  end
end
