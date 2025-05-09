# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Evaluation sorts evolvables based on their fitness and provides mechanisms to
  #   change the goal type and value (fitness goal). Goals define the success criteria
  #   for evolution. They allow you to specify what your population is evolving toward,
  #   whether it's maximizing a value, minimizing a value, or seeking a specific value.
  #
  #   **How It Works**
  #
  #   1. Your evolvable class defines a `#fitness` method that returns a
  #   [Comparable](https://docs.ruby-lang.org/en//3.4/Comparable.html) object.
  #      - Preferably a numeric value like an integer or float.
  #
  #   2. During evolution, evolvables are sorted by your goal's fitness interpretation
  #      - The default goal type is `:maximize`, see goal types below for other options
  #
  #   3. If a goal value is specified, evolution will stop when it is met
  #
  #   **Goal Types**
  #
  #   - Maximize (higher is better)
  #
  #   ```ruby
  #   robots = Robot.new_population(evaluation: :maximize) # Defaults to infinity
  #   robots.evolve(goal_value: 100) # Evolve until fitness reaches 100+
  #
  #   # Same as above
  #   Robot.new_population(evaluation: { maximize: 100 }).evolve
  #   ```
  #
  #   - Minimize (lower is better)
  #
  #   ```ruby
  #   errors = ErrorModel.new_population(evaluation: :minimize) # Defaults to -infinity
  #   errors.evolve(goal_value: 0.01)  # Evolve until error rate reaches 0.01 or less
  #
  #   # Same as above
  #   ErrorModel.new_population(evaluation: { minimize: 0.01 }).evolve
  #   ```
  #
  #   - Equalize (closer to target is better)
  #
  #   ```ruby
  #   targets = TargetMatcher.new_population(evaluation: :equalize) # Defaults to 0
  #   targets.evolve(goal_value: 42)  # Evolve until we match the target value
  #
  #   # Same as above
  #   TargetMatcher.new_population(evaluation: { equalize: 42 }).evolve
  #   ```
  #
  # @see Evolvable::Population
  # @see Evolvable::Selection
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
      when String
        goal_from_symbol(goal_arg.to_sym)
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
