# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Evaluation determines how evolvables are ranked based on their fitness scores and provides
  #   mechanisms to specify evolutionary goals (maximize, minimize, or equalize).
  #
  #   **How It Works**
  #
  #   1. Your evolvable class defines a `#fitness` method that returns a numeric score
  #   2. The evaluation's goal determines how this score is interpreted:
  #      - `maximize`: Higher values are better (default)
  #      - `minimize`: Lower values are better
  #      - `equalize`: Values closer to target are better
  #   3. During evolution, evolvables are sorted based on the goal's interpretation
  #   4. Evolution can stop when an evolvable reaches a specified goal value
  #
  # @see Evolvable::Population
  # @see Evolvable::Selection
  #
  # @example
  #   # Define an evolvable with a fitness function
  #   class Robot
  #     include Evolvable
  #
  #     gene :speed, type: SpeedGene, count: 1
  #     gene :sensors, type: SensorGene, count: 1..5
  #
  #     def fitness
  #       # Calculate fitness based on speed and sensor quality
  #       score = speed.value * 10
  #       score += sensors.sum(&:accuracy) * 5
  #       score -= sensors.size > 3 ? (sensors.size - 3) * 10 : 0 # Penalty for too many sensors
  #       score
  #     end
  #   end
  #
  #   # Different goal types
  #
  #   # 1. Maximize (higher is better)
  #   robots = Robot.new_population(evaluation: { maximize: true })
  #   robots.evolve(goal_value: 100)  # Until fitness reaches 100+
  #
  #   # 2. Minimize (lower is better)
  #   errors = ErrorModel.new_population(evaluation: { minimize: true })
  #   errors.evolve(goal_value: 0.01)  # Until error rate reaches 0.01 or less
  #
  #   # 3. Equalize (closer to target is better)
  #   targets = TargetMatcher.new_population(evaluation: { equalize: 42 })
  #   targets.evolve(goal_value: 42)  # Until we match the target value
  #
  class Evaluation
    #
    # Mapping of goal type symbols to their corresponding goal objects.
    # See the readme section above for details on each goal type.
    #
    # @return [Hash<Symbol, Evolvable::Goal>] Available goal objects by type
    #
    GOALS = { maximize: Evolvable::MaximizeGoal.new,
              minimize: Evolvable::MinimizeGoal.new,
              equalize: Evolvable::EqualizeGoal.new }.freeze

    #
    # The default goal type used if none is specified.
    # @return [Symbol] The default goal type (maximize)
    #
    DEFAULT_GOAL_TYPE = :maximize

    #
    # Initializes a new evaluation object.
    #
    # @param goal [Symbol, Hash, Evolvable::Goal] The goal type (:maximize, :minimize, :equalize),
    #   a hash specifying goal type and value, or a custom goal object
    #
    def initialize(goal = DEFAULT_GOAL_TYPE)
      @goal = normalize_goal(goal)
    end

    #
    # The goal object used for evaluation.
    # @return [Evolvable::Goal] The current goal object
    #
    attr_accessor :goal

    #
    # Evaluates and sorts all evolvables in the population according to the goal.
    #
    # @param population [Evolvable::Population] The population to evaluate
    # @return [Array<Evolvable>] The sorted evolvables
    #
    def call(population)
      population.evolvables.sort_by! { |evolvable| goal.evaluate(evolvable) }
    end

    #
    # Returns the best evolvable in the population according to the goal.
    #
    # @param population [Evolvable::Population] The population to evaluate
    # @return [Evolvable] The best evolvable based on the current goal
    #
    def best_evolvable(population)
      population.evolvables.max_by { |evolvable| goal.evaluate(evolvable) }
    end

    #
    # Checks if the goal has been met by any evolvable in the population.
    #
    # @param population [Evolvable::Population] The population to check
    # @return [Boolean] True if the goal has been met, false otherwise
    #
    def met_goal?(population)
      goal.met?(population.evolvables.last)
    end

    private

    #
    # Normalizes the goal parameter into a proper goal object.
    #
    # @param goal_arg [Symbol, Hash, Evolvable::Goal] The goal parameter
    # @return [Evolvable::Goal] A normalized goal object
    #
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

    #
    # Returns the default goal object.
    #
    # @return [Evolvable::Goal] The default goal object
    #
    def default_goal
      GOALS[DEFAULT_GOAL_TYPE]
    end

    #
    # Creates a goal object from a symbol.
    #
    # @param goal_arg [Symbol] The goal type symbol
    # @return [Evolvable::Goal] The corresponding goal object
    #
    def goal_from_symbol(goal_arg)
      GOALS[goal_arg]
    end

    #
    # Creates a goal object from a hash specifying the goal type and value.
    #
    # @param goal_arg [Hash] A hash with a single key-value pair
    # @return [Evolvable::Goal] The corresponding goal object with the specified value
    #
    def goal_from_hash(goal_arg)
      goal_type, value = goal_arg.first
      goal = GOALS[goal_type]
      goal.value = value
      goal
    end
  end
end
