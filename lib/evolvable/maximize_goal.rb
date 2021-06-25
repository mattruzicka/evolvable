# frozen_string_literal: true

module Evolvable
  class MaximizeGoal < Goal
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

  # Deprecated. Will be removed in 2.0
  # use Evolvable::MaximizeGoal instead
  class Goal::Maximize < MaximizeGoal; end
end
