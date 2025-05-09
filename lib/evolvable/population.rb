# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Populations orchestrate the evolutionary process through four key components:
  #
  #   1. **Evaluation**: Ranks instances by fitness
  #   2. **Selection**: Chooses parents for combination
  #   3. **Combination**: Creates offspring from parents
  #   4. **Mutation**: Adds genetic diversity
  #
  #   **Features**
  #
  #   - Easy configuration via parameters
  #   - Lifecycle hooks (`before_evaluation`, `before_evolution`, `after_evolution`)
  #   - Progress tracking with `best_evolvable`
  #   - Goal-based or generation-count evolution
  #   - Serialization for saving/restoring
  #
  #   **Configuration**
  #
  #   ```ruby
  #   population = MyEvolvable.new_population(
  #     size: 50,                            # Population size
  #     evaluation: { maximize: true },      # Fitness goal
  #     selection: { size: 10 },             # Parent selection count
  #     mutation: { probability: 0.2 }       # Mutation rate
  #   )
  #
  #   # Run evolution
  #   population.evolve(count: 20)           # For 20 generations
  #   # or
  #   population.evolve(goal_value: 100)     # Until fitness goal reached
  #   ```
  #
  # @example
  #   # Track evolution progress over generations
  #   population = Shape.new_population(size: 30)
  #
  #   10.times do |i|
  #     population.evolve(count: 1)
  #     best = population.best_evolvable
  #     puts "Generation #{i}: Best fitness = #{best.fitness}"
  #   end
  #
  #   # Get and use the best solution
  #   best_shape = population.best_evolvable
  #   puts "Final solution: #{best_shape}"
  #
  class Population
    extend Forwardable

    #
    # Loads a population from serialized data.
    #
    # @param data [String] The serialized population data
    # @return [Evolvable::Population] The loaded population
    #
    def self.load(data)
      dump_attrs = Serializer.load(data)
      new(**dump_attrs)
    end

    #
    # Initializes an Evolvable::Population.
    #
    # @param evolvable_type [Class] Required. The class of evolvables to create
    # @param id [String, nil] Optional identifier, not used by Evolvable internally
    # @param name [String, nil] Optional name, not used by Evolvable internally
    # @param size [Integer] The number of instances in the population (default: 0)
    # @param evolutions_count [Integer] The number of evolutions completed (default: 0)
    # @param gene_space [Evolvable::GeneSpace, nil] The gene space for initializing evolvables
    # @param parent_evolvables [Array<Evolvable>] Parent evolvables for breeding the next generation
    # @param selected_evolvables [Array<Evolvable>] Evolvables selected for combinations
    # @param evaluation [Evolvable::Evaluation, Hash] The evaluation strategy
    # @param evolution [Evolvable::Evolution, Hash] The evolution strategy
    # @param selection [Evolvable::Selection, Hash, nil] Optional selection strategy
    # @param combination [Evolvable::Combination, Hash, nil] Optional combination strategy
    # @param mutation [Evolvable::Mutation, Hash, nil] Optional mutation strategy
    # @param evolvables [Array<Evolvable>] Initial evolvables (will be supplemented if fewer than size)
    #
    def initialize(evolvable_type:,
                   id: nil,
                   name: nil,
                   size: 0,
                   evolutions_count: 0,
                   gene_space: nil,
                   parent_evolvables: [],
                   selected_evolvables: [],
                   evaluation: Evaluation.new,
                   evolution: Evolution.new,
                   selection: nil,
                   combination: nil,
                   mutation: nil,
                   evolvables: [])
      @id = id
      @evolvable_type = evolvable_type.is_a?(Class) ? evolvable_type : Object.const_get(evolvable_type)
      @name = name
      @size = size
      @evolutions_count = evolutions_count
      @gene_space = initialize_gene_space(gene_space)
      @parent_evolvables = parent_evolvables
      @selected_evolvables = selected_evolvables
      self.evaluation = evaluation
      @evolution = evolution
      self.selection = selection if selection
      self.combination = combination if combination
      self.mutation = mutation if mutation
      self.evolvables = evolvables || []
      new_evolvables(count: @size - evolvables.count)
    end

    #
    # Population properties
    #
    attr_accessor :id,
                  :evolvable_type,
                  :name,
                  :size,
                  :evolutions_count,
                  :gene_space,
                  :evolution,
                  :parent_evolvables,
                  :selected_evolvables,
                  :evolvables

    #
    # Delegate lifecycle hook methods to the evolvable type
    #
    def_delegators :evolvable_type,
                   :before_evaluation,
                   :before_evolution,
                   :after_evolution

    #
    # Delegate evolution component accessors to the evolution object
    #
    def_delegators :evolution,
                   :selection,
                   :selection=,
                   :combination,
                   :combination=,
                   :mutation,
                   :mutation=

    #
    # Convenience delegators for selection settings
    #
    def_delegator :selection, :size, :selection_size
    def_delegator :selection, :size=, :selection_size=

    #
    # Convenience delegators for mutation settings
    #
    def_delegator :mutation, :rate, :mutation_rate
    def_delegator :mutation, :rate=, :mutation_rate=
    def_delegator :mutation, :probability, :mutation_probability
    def_delegator :mutation, :probability=, :mutation_probability=

    #
    # The evaluation strategy used to assess evolvables
    # @return [Evolvable::Evaluation] The current evaluation object
    #
    attr_reader :evaluation

    #
    # Sets the evaluation strategy.
    #
    # @param val [Evolvable::Evaluation, Hash] The new evaluation strategy or configuration hash
    # @return [Evolvable::Evaluation] The updated evaluation object
    #
    def evaluation=(val)
      @evaluation = Evolvable.new_object(@evaluation, val, Evaluation)
    end

    #
    # Delegate goal accessors to the evaluation object
    #
    def_delegators :evaluation,
                   :goal,
                   :goal=

    #
    # Evolves the population for a specified number of generations or until a goal is met.
    #
    # @param count [Integer, Float] The number of evolutions to run (default: Float::INFINITY)
    # @param goal_value [Numeric, nil] Optional goal value to evolve toward
    # @return [Evolvable::Population] The evolved population
    #
    def evolve(count: Float::INFINITY, goal_value: nil)
      goal.value = goal_value if goal_value
      1.upto(count) do
        before_evaluation(self)
        evaluation.call(self)
        before_evolution(self)
        break if met_goal?

        evolution.call(self)
        self.evolutions_count += 1
        after_evolution(self)
      end
    end

    #
    # Evolves the population using a pre-selected set of evolvables.
    # This allows for custom selection beyond the built-in selection strategies.
    #
    # @param selected_evolvables [Array<Evolvable>] The evolvables selected for combinations
    # @return [Evolvable::Population] The evolved population
    #
    def evolve_selected(selected_evolvables)
      self.selected_evolvables = selected_evolvables
      before_evolution(self)
      evolution.call(self)
      self.evolutions_count += 1
      after_evolution(self)
    end

    #
    # Returns the best evolvable in the population according to the evaluation goal.
    #
    # @return [Evolvable] The best evolvable based on the current goal
    #
    def best_evolvable
      evaluation.best_evolvable(self)
    end

    #
    # Checks if the goal has been met by any evolvable in the population.
    #
    # @return [Boolean] True if the goal has been met, false otherwise
    #
    def met_goal?
      evaluation.met_goal?(self)
    end

    #
    # Creates a new evolvable instance with an optional genome.
    # If no genome is provided and there are parent evolvables,
    # a genome will be generated through combination.
    #
    # @param genome [Evolvable::Genome, nil] Optional genome for the new evolvable
    # @return [Evolvable] A new evolvable instance
    #
    def new_evolvable(genome: nil)
      return generate_evolvables(1).first unless genome || parent_evolvables.empty?

      evolvable = evolvable_type.new_evolvable(population: self,
                                               genome: genome || new_genome,
                                               generation_index: @evolvables.count)
      @evolvables << evolvable
      evolvable
    end

    #
    # Creates multiple new evolvable instances.
    #
    # @param count [Integer] The number of evolvables to create
    # @return [Array<Evolvable>] The newly created evolvables
    #
    def new_evolvables(count:)
      if parent_evolvables.empty?
        Array.new(count) { new_evolvable(genome: new_genome) }
      else
        evolvables = generate_evolvables(count)
        @evolvables ||= []
        @evolvables.concat evolvables
        evolvables
      end
    end

    #
    # Creates a new genome from the gene space.
    #
    # @return [Evolvable::Genome] A new genome
    #
    def new_genome
      gene_space.new_genome
    end

    #
    # Resets the population by clearing all evolvables and creating new ones.
    #
    # @return [Array<Evolvable>] The new collection of evolvables
    #
    def reset_evolvables
      self.evolvables = []
      new_evolvables(count: size)
    end

    #
    # Creates a cycle of parent genome pairs for combination.
    # Shuffles parent genomes and creates combinations of two.
    #
    # @return [Enumerator] A cycle of parent genome pairs
    #
    def new_parent_genome_cycle
      parent_evolvables.map(&:genome).shuffle!.combination(2).cycle
    end

    #
    # Serializes the population to a string.
    #
    # @param only [Array<Symbol>, nil] Optional list of attributes to include
    # @param except [Array<Symbol>, nil] Optional list of attributes to exclude
    # @return [String] The serialized population
    #
    def dump(only: nil, except: nil)
      Serializer.dump(dump_attrs(only: only, except: except))
    end

    #
    # List of attributes that can be dumped during serialization.
    #
    # @return [Array<Symbol>] The dumpable attributes
    #
    DUMP_METHODS = %i[evolvable_type
                      id
                      name
                      size
                      evolutions_count
                      gene_space
                      evolution
                      evaluation].freeze

    #
    # Returns a hash of attributes for serialization.
    #
    # @param only [Array<Symbol>, nil] Optional list of attributes to include
    # @param except [Array<Symbol>, nil] Optional list of attributes to exclude
    # @return [Hash] The attributes hash for serialization
    #
    def dump_attrs(only: nil, except: nil)
      attrs = {}
      dump_methods = only || DUMP_METHODS
      dump_methods -= except if except
      dump_methods.each { |m| attrs[m] = send(m) }
      attrs
    end

    private

    #
    # Initializes the gene space for the population.
    #
    # @param gene_space [Evolvable::GeneSpace, nil] Optional gene space configuration
    # @return [Evolvable::GeneSpace] The initialized gene space
    #
    def initialize_gene_space(gene_space)
      return GeneSpace.build(gene_space, evolvable_type) if gene_space

      evolvable_type.new_gene_space
    end

    #
    # Generates multiple evolvables through combination and mutation.
    #
    # @param count [Integer] The number of evolvables to generate
    # @return [Array<Evolvable>] The generated evolvables
    #
    def generate_evolvables(count)
      evolvables = combination.new_evolvables(self, count)
      mutation.mutate_evolvables(evolvables)
      evolvables
    end
  end
end
