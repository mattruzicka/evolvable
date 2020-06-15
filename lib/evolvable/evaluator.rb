# frozen_string_literal: true

module Evolvable
  class Evaluator
    GOALS_CACHE = { maximize: Evolvable::Goal::Maximize.new,
                    minimize: Evolvable::Goal::Minimize.new,
                    equalize: Evolvable::Goal::Equalize.new }.freeze

    def initialize(goal: :maxmize)
      @goal = normalize_goal(goal)
    end

    attr_accessor :goal

    def call!(population)
      population.evolvable_evaluate!(population)
    end

    def sort!(population)
      population.instances.sort_by! { |instance| goal.evaluate(instance) }
    end

    def best_instance(population)
      population.instances.max_by { |instance| goal.evaluate(instance) }
    end

    def met_goal?(population)
      goal.met?(population.instances.last)
    end

    private

    def normalize_goal(goal)
      case goal
      when Symbol
        goal_from_symbol(goal)
      when Hash
        goal_from_hash(goal_hash)
      else
        goal
      end
    end

    def goal_from_symbol(goal_type)
      GOALS_CACHE[goal_type]
    end

    def goal_from_hash(goal_hash)
      goal_type, value = goal_hash.first
      goal = GOALS_CACHE[goal_type]
      goal.value = value
      goal
    end
  end
end
