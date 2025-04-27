# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   For selection to be effective in the context of evolution, there needs to be
  #   a way to compare evolvables. In the genetic algorithm, this is often
  #   referred to as the "fitness function".
  #
  #   The `Evolvable::Evaluation` object expects evolvable instances to define a `#fitness` method that
  #   returns some numeric value. Fitness scores are used to evaluate instances relative to each
  #   other and with regards to some goal. Out of the box, the goal can be set
  #   to maximize, minimize, or equalize numeric values.
  #
  # @example
  #   # TODO: Show how to add/change population's evaluation object
  #
  #   # The goal value can also be assigned via as argument to `Evolvable::Population#evolve`
  #   population.evolve(goal_value: 1000)
  #
  class Evaluation
    GOALS = { maximize: Evolvable::MaximizeGoal.new,
              minimize: Evolvable::MinimizeGoal.new,
              equalize: Evolvable::EqualizeGoal.new }.freeze

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
