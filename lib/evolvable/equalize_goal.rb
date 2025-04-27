# frozen_string_literal: true

module Evolvable
  #
  # Prioritizes instances that equal the goal value.
  #
  # The default goal value is `0`, but it can be reassigned to any numeric value.
  #
  class EqualizeGoal < Goal
    def value
      @value ||= 0
    end

    def evaluate(evolvable)
      -(evolvable.fitness - value).abs
    end

    def met?(evolvable)
      evolvable.fitness == value
    end
  end
end
