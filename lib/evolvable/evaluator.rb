# frozen_string_literal: true

module Evolvable
  class Evaluator
    GOALS = { maximize: Evolvable::Goal::Maximize.new,
              minimize: Evolvable::Goal::Minimize.new,
              equalize: Evolvable::Goal::Equalize.new }.freeze

    def initialize(goal = :maxmize)
      @goal = normalize_goal(goal)
    end

    attr_accessor :goal

    def call(population)
      population.evolvable_evaluate!(population)
      population.instances.sort_by! { |instance| goal.evaluate(instance) }
    end

    def best_instance(population)
      population.instances.max_by { |instance| goal.evaluate(instance) }
    end

    def met_goal?(population)
      goal.met?(population.instances.last)
    end

    private

    def normalize_goal(goal_arg)
      case goal_arg
      when Symbol
        goal_from_symbol(goal_arg)
      when Hash
        goal_from_hash(goal_arg)
      else
        goal
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
