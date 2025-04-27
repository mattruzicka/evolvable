# frozen_string_literal: true

require 'forwardable'
require 'evolvable/version'
require 'evolvable/error/undefined_method'
require 'evolvable/gene'
require 'evolvable/gene_cluster'
require 'evolvable/gene_space'
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
require 'evolvable/community'

#
# @readme
#   The `Evolvable` module makes it possible to implement evolutionary behaviors for
#   any class. This is done through macro-style method calls that define the genetic
#   structure of your models and their fitness evaluation criteria.
#
#   By including the `Evolvable` module, using the `.gene` macro to declare genetic
#   attributes, and implementing a `#fitness` instance method, you can enable any Ruby
#   object to participate in evolutionary processes.
#
#   To evolve instances, initialize a population with `.new_population` and invoke
#   the `#evolve` method on the resulting population object.
#
#   ### Implementation Steps
#
#   1. [Include the `Evolvable` module in the class you want to evolve.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable)
#   2. [Define gene with the `.gene` method.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/GeneSpace)
#   3. [Define `#fitness`.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Evaluation)
#   4. [Initialize a population with `.new_population` and use `#evolve`.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Population)
#
module Evolvable
  extend Forwardable

  class Error < StandardError; end

  def self.included(base)
    base.instance_variable_set(:@gene_config, {})
    base.instance_variable_set(:@cluster_config, {})
    base.extend(ClassMethods)
  end

  def self.new_object(old_val, new_val, default_class)
    new_val.is_a?(Hash) ? (old_val&.class || default_class).new(**new_val) : new_val
  end

  module ClassMethods
    #
    # @readme
    #   Initializes a population with defaults that can be change dusing the same named parameters as
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
    def new_evolvable(population: nil, genome: nil, generation_index: nil)
      evolvable = initialize_evolvable
      evolvable.make_evolvable(population: population, genome: genome, generation_index: generation_index)
      evolvable.after_initialize_evolvable
      evolvable
    end

    def initialize_evolvable
      new
    end

    #
    # @readme
    #   A macro-style method that defines a gene for the evolving class. This creates the gene space entry
    #   and defines a getter method for accessing gene values.
    #
    # @param name [Symbol] The name of the gene
    # @param type [String, Class] The gene type or class name
    # @param count [Integer, Range] The number or range of genes to create
    # @param cluster [Symbol, nil] Optional cluster name to group related genes
    #
    # @example
    #   class Melody
    #     include Evolvable
    #
    #     gene :notes, type: NoteGene, count: 4..16
    #     gene :instrument, type: InstrumentGene, count: 1
    #
    #     def play
    #       instrument.play(notes)
    #     end
    #   end
    #
    # @readme
    #   A macro-style method that defines a gene for the evolving class. This creates
    #   the gene space entry and defines a getter method for accessing gene values.
    #
    #   These gene macros form the genetic structure of your evolutionary models,
    #   similar to how Active Record's association macros define relationships between models.
    #
    # @param name [Symbol] The name of the gene
    # @param type [String, Class] The gene type or class name
    # @param count [Integer, Range] The number or range of genes to create
    # @param cluster [Symbol, nil] Optional cluster name to group related genes
    #
    # @example
    #   class Melody
    #     include Evolvable
    #
    #     gene :notes, type: NoteGene, count: 4..16
    #     gene :instrument, type: InstrumentGene, count: 1
    #
    #     def play
    #       instrument.play(notes)
    #     end
    #   end
    #
    def gene(name, type:, count: 1, cluster: nil)
      raise Error, "Gene name '#{name}' is already defined" if @gene_config.key?(name)

      @gene_config[name] = { type: type, count: count }

      if (count.is_a?(Range) ? count.last : count) > 1
        define_method(name) { find_genes(name) }
      else
        define_method(name) { find_gene(name) }
      end

      if cluster
        raise Error, "Cluster name '#{cluster}' conflicts with an existing gene name" if @gene_config.key?(cluster)

        if @cluster_config[cluster]
          @cluster_config[cluster] << name
        else
          @cluster_config[cluster] = [name]
          define_method(cluster) { find_gene_cluster(cluster) }
        end
      end
    end

    def cluster(cluster_name, type:, **opts)
      recipe = type.is_a?(String) ? Object.const_get(type) : type
      unless recipe.respond_to?(:apply_cluster)
        raise ArgumentError, "#{recipe} cannot apply a gene cluster"
      end

      recipe.apply_cluster(self, cluster_name, **opts)

      define_method(cluster_name) { find_gene_cluster(cluster_name) }
    end

    attr_reader :gene_config, :cluster_config

    def new_gene_space
      GeneSpace.build(@gene_config, self)
    end

    def inherited(subclass)
      super
      subclass.instance_variable_set(:@gene_config, @gene_config.dup)
      subclass.instance_variable_set(:@cluster_config, @cluster_config.dup)
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

  def make_evolvable(population: nil, genome: nil, generation_index: nil)
    self.population = population
    self.genome = genome || population&.new_genome || Genome.new
    self.generation_index = generation_index
    self
  end

  # Runs when an evolvable is initialized. Ueful for implementing custom initialization logic.
  def after_initialize_evolvable; end

  #
  # @!method fitness
  #   Implementing this method is required for evaluation and selection.
  #
  attr_accessor :population,
                :genome,
                :generation_index,
                :fitness
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

  def find_gene_cluster(cluster)
    find_genes(*self.class.cluster_config[cluster])
  end

  def dump_genome(serializer: Serializer)
    @genome.dump(serializer: serializer)
  end

  def load_genome(data, serializer: Serializer)
    @genome = Genome.load(data, serializer: serializer)
  end

  def load_and_merge_genome!(data, serializer: Serializer)
    genome = Genome.load(data, serializer: serializer)
    merge_genome!(genome)
  end

  def merge_genome!(other_genome)
    @genome.merge!(other_genome)
  end
end
