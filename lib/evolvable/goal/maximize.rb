# frozen_string_literal: true

module Evolvable::Goal
  class Maximize
    include Evolvable::Goal

    def value
      @value ||= Float::INFINITY
    end

    def evaluate(object)
      object.value
    end

    def met?(object)
      object.value >= value
    end
  end
end
