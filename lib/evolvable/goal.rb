# frozen_string_literal: true

module Evolvable

  #
  # @readme
  #   Goals define the success criteria for evolution. They allow you to specify what your
  #   population is evolving toward, whether it's maximizing a value, minimizing a value,
  #   or reaching a specific target value.
  #
  #   Evolvable provides three built-in goal types:
  #   - **MaximizeGoal**: Higher fitness values are better (e.g., scoring more points)
  #   - **MinimizeGoal**: Lower fitness values are better (e.g., reducing errors)
  #   - **EqualizeGoal**: Values closer to a target are better (e.g., matching a pattern)
  #
  #   Each goal type influences:
  #   1. How evolvables are ranked during evaluation
  #   2. Which evolvables are selected as parents
  #   3. When to stop evolving if a goal value is reached
  #
  #   **Custom Goals**
  #
  #   You can create custom goals by subclassing Goal and implementing:
  #   - `evaluate(evolvable)`: Returns a value used to rank evolvables
  #   - `met?(evolvable)`: Returns true when the goal is reached
  #
  # @example Setting up a goal with a specific target value
  #   # Create a goal object with a target value of 100
  #   goal_object = Evolvable::MaximizeGoal.new(value: 100)
  #
  #   # Use it when initializing an evaluation
  #   evaluation = Evolvable::Evaluation.new(goal_object)
  #
  #   # Or set it on an existing population
  #   population.goal = goal_object
  #
  # @example Using shorthand goal configuration
  #   # Maximize fitness (default goal value is Float::INFINITY)
  #   Evolvable::Evaluation.new(:maximize)
  #
  #   # Maximize with a specific target value of 50
  #   Evolvable::Evaluation.new(maximize: 50)
  #
  #   # Minimize fitness (default goal value is -Float::INFINITY)
  #   Evolvable::Evaluation.new(:minimize)
  #
  #   # Minimize with a specific target value of 100
  #   Evolvable::Evaluation.new(minimize: 100)
  #
  #   # Equalize fitness (default target value is 0)
  #   Evolvable::Evaluation.new(:equalize)
  #
  #   # Equalize with a specific target value of 1000
  #   Evolvable::Evaluation.new(equalize: 1000)
  #
  # @example Creating a custom goal class
  #   class TargetRangeGoal < Evolvable::Goal
  #     def initialize(min: 0, max: 100, value: nil)
  #       super(value: value)
  #       @min = min
  #       @max = max
  #     end
  #
  #     # Used to rank instances by fitness
  #     def evaluate(instance)
  #       # Higher score when value is within range
  #       return 100 if @min <= instance.fitness && instance.fitness <= @max
  #       # Otherwise, negative score based on distance from range
  #       distance = [(@min - instance.fitness).abs, (@max - instance.fitness).abs].min
  #       -distance
  #     end
  #
  #     # Goal is met when fitness is within the target range
  #     def met?(instance)
  #       @min <= instance.fitness && instance.fitness <= @max
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
