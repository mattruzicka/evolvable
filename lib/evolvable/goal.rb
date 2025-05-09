# frozen_string_literal: true

module Evolvable
  #
  # @see Evolvable::Evaluation
  #
  # @readme
  #   **Custom Goals**
  #
  #   You can create custom goals by subclassing `Evolvable::Goal`` and implementing:
  #   - `evaluate(evolvable)`: Return a value that for sorting evolvables
  #   - `met?(evolvable)`: Returns true when the goal value is reached
  #
  # @example Example goal implementation that prioritizes evolvables with fitness values within a specific range
  #   class YourRangeGoal < Evolvable::Goal
  #     def value
  #       @value ||= 0..100
  #      end
  #
  #     def evaluate(evolvable)
  #       return 1 if value.include?(evolvable.fitness)
  #
  #       min, max = value.minmax
  #       -[(min - evolvable.fitness).abs, (max - evolvable.fitness).abs].min
  #     end
  #
  #     def met?(evolvable)
  #       value.include?(evolvable.fitness)
  #     end
  #   end
  #
  class Goal
    def initialize(value: nil)
      @value = value if value
    end

    attr_accessor :value

    def evaluate(_evolvable)
      raise Error, "Undefined method: #{self.class.name}##{__method__}"
    end

    def met?(_evolvable)
      raise Error, "Undefined method: #{self.class.name}##{__method__}"
    end
  end
end
