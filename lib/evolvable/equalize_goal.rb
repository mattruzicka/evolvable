# frozen_string_literal: true

module Evolvable
  class EqualizeGoal < Goal
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

  # Deprecated. Will be removed in 2.0
  # use Evolvable::EqualizeGoal instead
  class Goal::Equalize < EqualizeGoal; end
end
