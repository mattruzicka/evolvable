# frozen_string_literal: true

module Evolvable
  #
  # Prioritizes instances with greater values. This is the default.
  #
  # The default goal value is `Float::INFINITY`, but it can be reassigned
  # to any numeric value.
  #
  class MaximizeGoal < Goal
    def value
      @value ||= Float::INFINITY
    end

    def evaluate(evolvable)
      evolvable.fitness
    end

    def met?(evolvable)
      evolvable.fitness >= value
    end
  end
end
