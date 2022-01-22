# frozen_string_literal: true

require 'forwardable'
require 'evolvable/version'
require 'evolvable/error/undefined_method'
require 'evolvable/gene'
require 'evolvable/search_space'
require 'evolvable/genome'
require 'evolvable/goal'
require 'evolvable/equalize_goal'
require 'evolvable/maximize_goal'
require 'evolvable/minimize_goal'
require 'evolvable/evaluation'
require 'evolvable/evolution'
require 'evolvable/selection'
require 'evolvable/gene_combination'
require 'evolvable/point_crossover'
require 'evolvable/uniform_crossover'
require 'evolvable/mutation'
require 'evolvable/population'
require 'evolvable/count_gene'
require 'evolvable/rigid_count_gene'
require 'evolvable/serializer'

#
# @readme
#   The `Evolvable` module makes it possible to implement evolutionary behaviors for
#   any class by defining a `.search_space` class method and `#value` instance method.
#   Then to evolve instances, initialize a population with `.new_population` and invoke
#   the `#evolve` method on the resulting population object.
#
#   ### Implementation Steps
#
#   1. [Include the `Evolvable` module in the class you want to evolve.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable)
#   2. [Define `.search_space` and any gene classes that you reference.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/SearchSpace)
#   3. [Define `#value`.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Evaluation)
#   4. [Initialize a population with `.new_population` and use `#evolve`.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Population)
#
module Evolvable
  extend Forwardable

  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.new_object(old_val, new_val, default_class)
    new_val.is_a?(Hash) ? (old_val&.class || default_class).new(**new_val) : new_val
  end

  module ClassMethods
    #
    # @readme
    #   Initializes a population using configurable defaults that can be configured and optimized.
    #   Accepts the same named parameters as
    #   [Population#initialize](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Population#initialize).
    #
    def new_population(keyword_args = {})
      keyword_args[:evolvable_type] = self
      Population.new(**keyword_args)
    end

    #
    # Initializes a new instance. Accepts a population object, an array of gene objects,
    # and the instance's population index. This method is useful for re-initializing
    # instances and populations that have been saved.
    #
    # _It is not recommended that you override this method_ as it is used by
    # Evolvable internals. If you need to customize how your instances are
    # initialized you can override either of the following two "initialize_instance"
    # methods.
    #
    def new_evolvable(population: nil,
                      genome: Genome.new,
                      generation_index: nil)
      evolvable = initialize_evolvable
      evolvable.population = population
      evolvable.genome = genome
      evolvable.generation_index = generation_index
      evolvable.after_initialize
      evolvable
    end

    def initialize_evolvable
      new
    end

    def new_search_space
      space_config = search_space.empty? ? gene_space : search_space
      search_space = SearchSpace.build(space_config, self)
      search_spaces.each { |space| search_space.merge_search_space!(space) }
      search_space
    end

    #
    # @abstract
    #
    # This method is responsible for configuring the available gene types
    # of evolvable instances. In effect, it provides the
    # blueprint for constructing a hyperdimensional genetic space that's capable
    # of being used and searched by evolvable objects.
    #
    # Override this method with a search space config for initializing
    # SearchSpace objects. The config can be a hash, array of arrays,
    # or single array when there's only one type of gene.
    #
    # The below example definitions could conceivably be used to generate evolvable music.
    #
    # @todo
    #   Define gene config attributes - name, type, count
    #
    # @example Hash config
    #   def search_space
    #     { instrument: { type: InstrumentGene, count: 1..4 },
    #       notes: { type: NoteGene, count: 16 } }
    #   end
    # @example Array of arrays config
    #   # With explicit gene names
    #   def search_space
    #     [[:instrument, InstrumentGene, 1..4],
    #      [:notes, NoteGene, 16]]
    #   end
    #
    #   # Without explicit gene names
    #   def search_space
    #     [[SynthGene, 0..4], [RhythmGene, 0..8]]
    #   end
    # @example Array config
    #   # Available when when just one type of gene
    #   def search_space
    #     [NoteGene, 1..100]
    #   end
    #
    #   # With explicit gene type name.
    #   def search_space
    #     ['notes', 'NoteGene', 1..100]
    #   end
    #
    # @return [Hash, Array]
    #
    # @see https://github.com/mattruzicka/evolvable#search_space
    #
    def search_space
      {}
    end

    #
    # @abstract Override this method to define multiple search spaces
    #
    # @return [Array]
    #
    # @see https://github.com/mattruzicka/evolvable#search_space
    #
    def search_spaces
      []
    end

    # @deprecated
    #   Will be removed in version 2.0.
    #   Use {#search_space} instead.
    def gene_space
      {}
    end


    #
    # @readme
    #   Runs before evaluation.
    #
    def before_evaluation(population); end

    #
    # @readme
    #   Runs after evaluation and before evolution.
    #
    # @example
    #   class Melody
    #     include Evolvable
    #
    #     # Play the best melody from each generation
    #     def self.before_evolution(population)
    #       population.best_evolvable.play
    #     end
    #
    #     # ...
    #   end
    #
    def before_evolution(population); end

    #
    # @readme
    #   Runs after evolution.
    #
    def after_evolution(population); end
  end

  # Runs an evolvable is initialized. Ueful for implementing custom initialization logic.
  def after_initialize; end

  #
  # @!method value
  #   Implementing this method is required for evaluation and selection.
  #
  attr_accessor :id,
                :population,
                :genome,
                :generation_index,
                :value

  #
  # @deprecated
  #   Will be removed in version 2.0.
  #   Use {#generation_index} instead.
  #
  def population_index
    generation_index
  end

  #
  # @!method find_gene
  #   @see Genome#find_gene
  # @!method find_genes
  #   @see Genome#find_genes
  # @!method find_genes_count
  #   @see Genome#find_genes_count
  # @!method genes
  #   @see Genome#genes
  #
  def_delegators :genome,
                 :find_gene,
                 :find_genes,
                 :find_genes_count,
                 :genes

  def dump_genome(serializer: Serializer)
    @genome.dump(serializer: serializer)
  end

  def load_genome(data, serializer: Serializer)
    @genome = Genome.load(data, serializer: serializer)
  end
end
