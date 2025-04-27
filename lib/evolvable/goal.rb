# frozen_string_literal: true

module Evolvable

  #
  # The goal for a population can be specified via assignment - `population.goal = Evolvable::Goal::Equalize.new` - or by passing an evaluation object when [initializing a population](#evolvablepopulationnew).
  #
  # You can intialize the `Evolvable::Evaluation` object with any goal object like this:
  #
  # You can implement custom goal object like so:
  #
  # @example
  #   goal_object = SomeGoal.new(value: 100)
  #   Evolvable::Evaluation.new(goal_object)
  #
  # or more succinctly like this:
  #
  # @example
  #   Evolvable::Evaluation.new(:maximize) # Uses default goal value of   Float::INFINITY
  #   Evolvable::Evaluation.new(maximize: 50) # Sets goal value to 50
  #   Evolvable::Evaluation.new(:minimize) # Uses default goal value of   -Float::INFINITY
  #   Evolvable::Evaluation.new(minimize: 100) # Sets goal value to 100
  #   Evolvable::Evaluation.new(:equalize) # Uses default goal value of 0
  #   Evolvable::Evaluation.new(equalize: 1000) # Sets goal value to 1000
  #
  # @example
  #   class CustomGoal < Evolvable::Goal
  #     def evaluate(instance)
  #       # Required by Evolvable::Evaluation in order to sort instances in preparation for selection.
  #     end
  #
  #     def met?(instance)
  #       # Used by Evolvable::Population#evolve to stop evolving when the goal value has been reached.
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
