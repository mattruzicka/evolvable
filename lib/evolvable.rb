# frozen_string_literal: true

require 'forwardable'
require 'evolvable/version'
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
#   The evolutionary process works through these components:
#     1. **Populations**: Groups of the "evolvable" instances you define
#     2. **Genes**: Ruby objects that cache data for evolvables
#     3. **Evaluation**: Sorts evolvables by fitness
#     4. **Evolution**: Selection, combination, and mutation to generate new evolvables
#
#   Quick start:
#     1. Include `Evolvable` in your Ruby class
#     2. Define genes with the macro-style `gene` method
#     3. Have the `#fitness` method return a numeric value
#     4. Initialize a population and evolve it
#
#   Example population of "shirts" with various colors, buttons, and collars.
#
#     ```ruby
#     # Step 1
#     class Shirt
#       include Evolvable
#
#       # Step 2
#       gene :color, type: ColorGene # count: 1 default
#       gene :buttons, type: ButtonGene, count: 0..10 # Builds an array of genes that can vary in size
#       gene :collar, type: CollarGene, count: 0..1 # Collar optional
#
#       # Step 3
#       attr_accessor :fitness
#     end
#
#     # Step 4
#     population = Shirt.new_population(size: 10)
#     population.evolvables.each { |shirt| shirt.fitness = tried_it_on_score }
#     ```
#
#   You are free to tailor the genes to your needs and "try it on" yourself.
#
#   The `ColorGene` could be as simple as this:
#
#     ```ruby
#     class ColorGene
#       include Evolvable::Gene
#
#       def to_s
#         @to_s ||= %w[red green blue].sample
#       end
#     end
#     ```
#
#   Not into shirts?
#
#   Here's a [Hello World](https://github.com/mattruzicka/evolvable/blob/main/exe/hello_evolvable_world) command line demo.
#
module Evolvable
  extend Forwardable

  #
  # Error class for Evolvable-specific exceptions.
  #
  class Error < StandardError; end

  #
  # Called when the Evolvable module is included in a class.
  # Sets up the necessary instance variables and extends the class with ClassMethods.
  #
  # @param base [Class] The class that is including the Evolvable module
  # @return [void]
  #
  def self.included(base)
    base.instance_variable_set(:@gene_config, {})
    base.instance_variable_set(:@cluster_config, {})
    base.extend(ClassMethods)
  end

  #
  # Helper method for creating or updating objects with hash parameters.
  # This is used internally for creating evaluation, selection, mutation, etc. objects
  # from configuration hashes.
  #
  # @param old_val [Object, nil] The existing object to update, if any
  # @param new_val [Object, Hash] The new object or configuration hash
  # @param default_class [Class] The default class to instantiate if new_val is a Hash
  # @return [Object] The new or updated object
  #
  def self.new_object(old_val, new_val, default_class)
    new_val.is_a?(Hash) ? (old_val&.class || default_class).new(**new_val) : new_val
  end

  module ClassMethods
    #
    # @readme
    #   Initializes a population with defaults that can be changed using the same named parameters as
    #   [Population#initialize](https://mattruzicka.github.io/evolvable/Evolvable/Population#initialize).
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

    #
    # Override this method to customize how your evolvable instances are initialized.
    # By default, simply calls new with no arguments.
    #
    # @return [Evolvable] A new evolvable instance
    #
    def initialize_evolvable
      new
    end

    #
    # @readme
    #   The `.gene` macro defines traits that can mutate and evolve over time.
    #   Syntactically similar to ActiveRecord-style macros, it sets up the genetic structure of your model.
    #
    #   Key features:
    #   - Fixed or variable gene counts
    #   - Automatic accessor methods
    #   - Optional clustering for related genes
    #
    # @example Basic gene definition
    #   class Melody
    #     include Evolvable
    #
    #     gene :notes, type: NoteGene, count: 4..16 # Can have 4-16 notes
    #     gene :instrument, type: InstrumentGene, count: 1
    #
    #     def play
    #       instrument.play(notes)
    #     end
    #   end
    #
    # @param name [Symbol] The name of the gene
    # @param type [String, Class] The gene type or class name
    # @param count [Integer, Range] Number or range of gene instances
    # @param cluster [Symbol, nil] Optional cluster name for grouping related genes
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

    #
    # @readme
    #   The `.cluster` macro applies a pre-defined group of related genes.
    #
    #   Clusters promote code organization through:
    #     - Modularity: Define related genes once, reuse them
    #     - Organization: Group genes by function
    #     - Maintenance: Update in one place
    #     - Accessibility: Access via a single accessor
    #
    # @example UI Component with Styling Cluster
    #   # Define a gene cluster for UI styling properties
    #   class ColorSchemeCluster
    #     include Evolvable::GeneCluster
    #
    #     gene :background_color, type: 'ColorGene', count: 1
    #     gene :text_color, type: 'ColorGene', count: 1
    #     gene :accent_color, type: 'ColorGene', count: 0..1
    #   end
    #
    #   # Use the cluster in an evolvable UI component
    #   class Button
    #     include Evolvable
    #
    #     cluster :colors, type: ColorSchemeCluster
    #     gene :padding, type: PaddingGene, count: 1
    #
    #     def render
    #       puts "Button with #{colors.count} colors"
    #       puts "Background: #{colors.background_color.hex_code}"
    #     end
    #   end
    #
    # @param cluster_name [Symbol] The name for accessing the cluster
    # @param type [Class, String] The class that defines the cluster
    # @param opts [Hash] Optional arguments passed to the cluster initializer
    #
    def cluster(cluster_name, type:, **opts)
      recipe = type.is_a?(String) ? Object.const_get(type) : type
      unless recipe.respond_to?(:apply_cluster)
        raise ArgumentError, "#{recipe} cannot apply a gene cluster"
      end

      recipe.apply_cluster(self, cluster_name, **opts)

      define_method(cluster_name) { find_gene_cluster(cluster_name) }
    end

    attr_reader :gene_config, :cluster_config

    #
    # Creates a new gene space for this evolvable class.
    # Used internally when initializing populations.
    #
    # @return [Evolvable::GeneSpace] A new gene space
    #
    def new_gene_space
      GeneSpace.build(@gene_config, self)
    end

    #
    # Ensures that subclasses inherit the gene and cluster configuration.
    #
    # @param subclass [Class] The subclass that is inheriting from this class
    # @return [void]
    #
    def inherited(subclass)
      super
      subclass.instance_variable_set(:@gene_config, @gene_config.dup)
      subclass.instance_variable_set(:@cluster_config, @cluster_config.dup)
    end

    #
    # @readme
    #   Called before evaluation.
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

  def after_initialize_evolvable; end

  def find_gene(name)
    return nil if @genome.nil?

    genes = @genome[name]&.dig(:genes)
    return nil if genes.nil? || genes.empty?

    genes.first
  end

  def find_genes(name)
    return [] if @genome.nil?

    @genome[name]&.dig(:genes) || []
  end

  attr_reader :population,
              :genome,
              :generation_index

  def genes
    @genome&.genes || []
  end

  #
  # Makes this object evolvable by setting up its population, genome, and generation index.
  # This is called internally by the class method `new_evolvable`.
  #
  # @param population [Evolvable::Population, nil] The population this evolvable belongs to
  # @param genome [Evolvable::Genome, nil] The genome to initialize with
  # @param generation_index [Integer, nil] The generation index
  # @return [self] This evolvable object
  #
  def make_evolvable(population: nil, genome: nil, generation_index: nil)
    self.population = population
    @genome = genome
    self.generation_index = generation_index
    self
  end

  def population=(val)
    @population = val
    genes.each { |gene| gene.evolvable = self if gene.respond_to?(:evolvable=) }
  end

  def generation_index=(val)
    @generation_index = val
  end

  #
  # Finds an array of genes that belong to the specified cluster.
  # This is used internally when accessing gene clusters.
  #
  # @param cluster [Symbol] The cluster name
  # @return [Array<Evolvable::Gene>] The genes belonging to the cluster
  #
  def find_gene_cluster(cluster)
    find_genes(*self.class.cluster_config[cluster])
  end

  #
  # Dumps the genome to a serialized format.
  # Useful for saving the state of an evolvable.
  #
  # @param serializer [Evolvable::Serializer] The serializer to use
  # @return [String] The serialized genome
  #
  def dump_genome(serializer: Serializer)
    @genome.dump(serializer: serializer)
  end

  #
  # Loads a genome from serialized data.
  # Useful for restoring the state of an evolvable.
  #
  # @param data [String] The serialized genome data
  # @param serializer [Evolvable::Serializer] The serializer to use
  # @return [Evolvable::Genome] The loaded genome
  #
  def load_genome(data, serializer: Serializer)
    @genome = Genome.load(data, serializer: serializer)
  end

  #
  # Loads a genome from serialized data and merges it with the current genome.
  # Useful for combining genomes from different sources.
  #
  # @param data [String] The serialized genome data
  # @param serializer [Evolvable::Serializer] The serializer to use
  # @return [Evolvable::Genome] The merged genome
  #
  def load_and_merge_genome!(data, serializer: Serializer)
    genome = Genome.load(data, serializer: serializer)
    merge_genome!(genome)
  end

  #
  # Merges another genome into this evolvable's genome.
  # Useful for combining genetic traits from different evolvables.
  #
  # @param other_genome [Evolvable::Genome] The genome to merge
  # @return [Evolvable::Genome] The merged genome
  #
  def merge_genome!(other_genome)
    @genome.merge!(other_genome)
  end
end
