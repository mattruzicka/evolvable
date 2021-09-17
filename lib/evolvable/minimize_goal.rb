# frozen_string_literal: true

module Evolvable
  # Prioritizes instances with lesser values.
  #
  # The default goal value is `-Float::INFINITY`, but it can be reassigned
  # to any numeric value
  #
  class MinimizeGoal < Goal
    def value
      @value ||= -Float::INFINITY
    end

    def evaluate(evolvable)
      -evolvable.value
    end

    def met?(evolvable)
      evolvable.value <= value
    end
  end

  #
  # @deprecated
  #   Will be removed in 2.0.
  #   Use {MinimizeGoal} instead
  #
  class Goal::Minimize < MinimizeGoal; end
end
