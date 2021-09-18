# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   For selection to be effective in the context of evolution, there needs to be
  #   a way to compare evolvables. In the genetic algorithm, this is often
  #   referred to as the "fitness function".
  #
  #   The Evaluation object expects evolvable instances to define a `#value` method that
  #   returns some numeric value. Values are used to evaluate instances relative to each
  #   other and with regards to some goal. Out of the box, the goal can be
  #   to maximize, minimize, or equalize some numeric value.
  #
  # A population's goal value can be most easily assigned via  an argument to
  # `Evolvable::Population#evolve` like this: population.evolve(goal_value: 1000).
  #
  class Evaluation
    GOALS = { maximize: Evolvable::Goal::Maximize.new,
              minimize: Evolvable::Goal::Minimize.new,
              equalize: Evolvable::Goal::Equalize.new }.freeze

    DEFAULT_GOAL_TYPE = :maximize

    def initialize(goal = DEFAULT_GOAL_TYPE)
      @goal = normalize_goal(goal)
    end

    attr_accessor :goal

    def call(population)
      population.evolvables.sort_by! { |evolvable| goal.evaluate(evolvable) }
    end

    def best_evolvable(population)
      population.evolvables.max_by { |evolvable| goal.evaluate(evolvable) }
    end

    def met_goal?(population)
      goal.met?(population.evolvables.last)
    end

    private

    def normalize_goal(goal_arg)
      case goal_arg
      when Symbol
        goal_from_symbol(goal_arg)
      when Hash
        goal_from_hash(goal_arg)
      else
        goal_arg || default_goal
      end
    end

    def default_goal
      GOALS[DEFAULT_GOAL_TYPE]
    end

    def goal_from_symbol(goal_arg)
      GOALS[goal_arg]
    end

    def goal_from_hash(goal_arg)
      goal_type, value = goal_arg.first
      goal = GOALS[goal_type]
      goal.value = value
      goal
    end
  end
end
