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
      evolvable.value
    end

    def met?(evolvable)
      evolvable.value >= value
    end
  end

  #
  # @deprecated
  #   Will be removed in 2.0.
  #   Use {MaximizeGoal} instead
  #
  class Goal::Maximize < MaximizeGoal; end
end
