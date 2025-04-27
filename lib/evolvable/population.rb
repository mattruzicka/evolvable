# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Population objects are responsible for generating and evolving instances.
  #   They orchestrate all the other Evolvable objects to do so.
  #
  #   Populations can be initialized and re-initialized with a number of useful
  #   parameters.
  #
  # @example
  #   # TODO: initialize a population with all supported parameters
  class Population
    extend Forwardable

    def self.load(data)
      dump_attrs = Serializer.load(data)
      new(**dump_attrs)
    end

    # Initializes an Evolvable::Population.
    # Keyword arguments:
    # #### evolvable_type
    # Required. Implicitly specified when using EvolvableClass.new_population.
    # #### id, name
    # Both default to `nil`. Not used by Evolvable, but convenient when working
    # with multiple populations.
    # #### size
    # Defaults to `40`. Specifies the number of instances in the population.
    # #### evolutions_count
    # Defaults to `0`. Useful when re-initializing a saved population with instances.
    # #### gene_space
    # Defaults to `evolvable_type.new_gene_space` which uses the
    # [EvolvableClass.gene_space](#evolvableclassgene_space) method
    # #### evolution
    # Defaults to `Evolvable::Evolution.new`. See [evolution](#evolution-1)
    # #### evaluation
    # Defaults to `Evolvable::Evaluation.new`, with a goal of maximizing
    # towards Float::INFINITY. See [evaluation](#evaluation-1)
    # #### instances
    # Defaults to initializing a `size` number of `evolvable_type`
    # instances using the `gene_space` object. Any given instances
    # are assigned, but if given less than `size`, more will be initialized.
    #
    def initialize(evolvable_type:,
                   id: nil,
                   name: nil,
                   size: 40,
                   evolutions_count: 0,
                   gene_space: nil,
                   parent_evolvables: [],
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
      @gene_space = initialize_gene_space(gene_space || gene_space)
      @parent_evolvables = parent_evolvables
      self.evaluation = evaluation
      @evolution = evolution
      self.selection = selection if selection
      self.combination = combination if combination
      self.mutation = mutation if mutation
      @evolvables = new_evolvables(count: @size - evolvables.count, evolvables: evolvables)
    end

    attr_accessor :id,
                  :evolvable_type,
                  :name,
                  :size,
                  :evolutions_count,
                  :gene_space,
                  :evolution,
                  :parent_evolvables,
                  :evolvables

    def_delegators :evolvable_type,
                   :before_evaluation,
                   :before_evolution,
                   :after_evolution

    def_delegators :evolution,
                   :selection,
                   :selection=,
                   :combination,
                   :combination=,
                   :mutation,
                   :mutation=

    def_delegator :selection, :size, :selection_size
    def_delegator :selection, :size=, :selection_size=

    def_delegator :mutation, :rate, :mutation_rate
    def_delegator :mutation, :rate=, :mutation_rate=
    def_delegator :mutation, :probability, :mutation_probability
    def_delegator :mutation, :probability=, :mutation_probability=

    attr_reader :evaluation

    def evaluation=(val)
      @evaluation = Evolvable.new_object(@evaluation, val, Evaluation)
    end

    def_delegators :evaluation,
                   :goal,
                   :goal=

    #
    #  Keyword arguments:
    #
    #  #### count
    #  The number of evolutions to run. Expects a positive integer
    #  and Defaults to Float::INFINITY and will therefore run indefinitely
    #  unless a `goal_value` is specified.
    #  #### goal_value
    #  Assigns the goal object's value. Will continue running until any
    #  instance's value reaches it. See [evaluation](#evaluation-1)
    #
    #  ### Evolvable::Population#best_instance
    #  Returns an instance with the value that is nearest to the goal value.
    #
    #  ### Evolvable::Population#met_goal?
    #  Returns true if any instance's value matches the goal value, otherwise false.
    #
    #  ### Evolvable::Population#new_instance
    #  Initializes an instance for the population. Note that this method does not
    #  add the new instance to its array of instances.
    #
    #  Keyword arguments:
    #
    #  #### genes
    #  An array of initialized gene objects. Defaults to `[]`
    #  #### population_index
    #  Defaults to `nil` and expects an integer.
    #
    # See (EvolvableClass#population_index)[#evolvableclasspopulation_index-population_index]
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

    def best_evolvable
      evaluation.best_evolvable(self)
    end

    def met_goal?
      evaluation.met_goal?(self)
    end

    def new_evolvable(genome: nil)
      return generate_evolvables(1).first unless genome || parent_evolvables.empty?

      evolvable = evolvable_type.new_evolvable(population: self,
                                               genome: genome || gene_space.new_genome,
                                               generation_index: @evolvables.count)
      @evolvables << evolvable
      evolvable
    end

    def new_evolvables(count:, evolvables: nil)
      evolvables ||= @evolvables || []
      @evolvables = evolvables

      if parent_evolvables.empty?
        Array.new(count) { new_evolvable(genome: gene_space.new_genome) }
      else
        @evolvables = generate_evolvables(count)
      end
    end

    def reset_evolvables
      self.evolvables = []
      new_evolvables(count: size)
    end

    def new_parent_genome_cycle
      parent_evolvables.map(&:genome).shuffle!.combination(2).cycle
    end

    def dump(only: nil, except: nil)
      Serializer.dump(dump_attrs(only: only, except: except))
    end

    DUMP_METHODS = %i[evolvable_type
                      id
                      name
                      size
                      evolutions_count
                      gene_space
                      evolution
                      evaluation].freeze

    def dump_attrs(only: nil, except: nil)
      attrs = {}
      dump_methods = only || DUMP_METHODS
      dump_methods -= except if except
      dump_methods.each { |m| attrs[m] = send(m) }
      attrs
    end

    private

    def initialize_gene_space(gene_space)
      return GeneSpace.build(gene_space, evolvable_type) if gene_space

      evolvable_type.new_gene_space
    end

    def generate_evolvables(count)
      evolvables = combination.new_evolvables(self, count)
      mutation.mutate_evolvables(evolvables)
      evolvables
    end
  end
end
