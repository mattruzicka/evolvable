module Evolvable
  class Evaluator
    GOALS = { maximize: Evolvable::Goal::Maximize.new,
              minimize: Evolvable::Goal::Minimize.new,
              equalize: Evolvable::Goal::Equalize.new }

    def initialize(goal: :maxmize)
      @goal = normalize_goal(goal)
    end

    attr_accessor :goal

    def call!(population)
      population.evolvable_evaluate!(population)
    end

    def sort!(population)
      population.objects.sort_by! { |object| goal.evaluate(object) }
    end

    def best_object(population)
      population.objects.max_by { |object| goal.evaluate(object) }
    end

    def met_goal?(population)
      goal.met?(population.objects.last)
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
      GOALS[goal_type]
    end

    def goal_from_hash(goal_hash)
      goal_type, value = goal_hash.first
      goal = GOALS[goal_type]
      goal.value = value
      goal
    end
  end
end
