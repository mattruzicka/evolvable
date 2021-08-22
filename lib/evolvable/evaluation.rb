# frozen_string_literal: true

module Evolvable
  class Evaluation
    GOALS = { maximize: Evolvable::Goal::Maximize.new,
              minimize: Evolvable::Goal::Minimize.new,
              equalize: Evolvable::Goal::Equalize.new }.freeze

    def initialize(goal = :maximize)
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
        goal_arg
      end
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
