# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Mutation introduces genetic variation by randomly replacing genes with new
  #   ones. This helps the population explore new areas of the solution space
  #   and prevents premature convergence on suboptimal solutions.
  #
  #   Mutation is controlled by two key parameters:
  #   - **probability**: Likelihood that an individual will undergo mutation (range: 0.0–1.0)
  #   - **rate**: Fraction of genes to mutate within those individuals (range: 0.0–1.0)
  #
  #   A typical strategy is to start with higher mutation to encourage exploration:
  #
  #   ```ruby
  #   population = MyEvolvable.new_population(
  #     mutation: { probability: 0.4, rate: 0.2 }
  #   )
  #   ```
  #
  #   Then later reduce the mutation rate to focus on refinement and convergence:
  #
  #   ```ruby
  #   population.mutation_probability = 0.1
  #   population.mutation_rate = 0.05
  #   ```
  #
  class Mutation
    extend Forwardable

    #
    # The default probability of mutation (3%).
    # This is used when no probability is specified.
    #
    DEFAULT_PROBABILITY = 0.03

    #
    # Initializes a new mutation object.
    #
    # @example Basic initialization patterns
    #   # Default: 3% of instances get one mutated gene
    #   Evolvable::Mutation.new
    #
    #   # 50% of instances get one mutated gene
    #   Evolvable::Mutation.new(probability: 0.5)
    #
    #   # All instances are considered, with 3% of genes mutating in each
    #   Evolvable::Mutation.new(rate: 0.03)
    #
    #   # 30% of instances have 3% of their genes mutated
    #   Evolvable::Mutation.new(probability: 0.3, rate: 0.03)
    #
    # When rate is specified but probability isn't, probability defaults to 1.0.
    # When rate is 0 or not specified, only one gene is mutated per affected instance.
    #
    # @param probability [Float, nil] Chance of an instance being mutated (0.0-1.0)
    # @param rate [Float, nil] Chance of each gene mutating when an instance is selected (0.0-1.0)
    #
    def initialize(probability: nil, rate: nil)
      @probability = probability || (rate ? 1 : DEFAULT_PROBABILITY)
      @rate = rate
    end

    #
    # The probability that an evolvable instance will undergo mutation.
    # Value between 0.0 (never) and 1.0 (always).
    #
    # @return [Float] The mutation probability
    #
    attr_accessor :probability

    #
    # The rate at which genes mutate within an instance.
    # Value between 0.0 (no genes mutate) and 1.0 (all genes likely to mutate).
    # When nil, exactly one random gene is mutated per instance.
    #
    # @return [Float, nil] The mutation rate
    #
    attr_accessor :rate

    #
    # Applies mutations to the population's evolvables based on the
    # configured probability and rate.
    #
    # @param population [Evolvable::Population] The population to mutate
    # @return [Evolvable::Population] The mutated population
    #
    def call(population)
      mutate_evolvables(population.evolvables) unless probability.zero?
      population
    end

    #
    # Mutates a collection of evolvable instances based on the mutation
    # probability and rate.
    #
    # @param evolvables [Array<Evolvable>] The collection of evolvable instances to potentially mutate
    # @return [Array<Evolvable>] The potentially mutated evolvables
    #
    def mutate_evolvables(evolvables)
      evolvables.each do |evolvable|
        next unless rand <= probability

        evolvable.genome.each { |_key, config| mutate_genes(config[:genes]) }
      end
    end

    private

    #
    # Mutates genes in the given collection based on the mutation rate.
    # If a rate is set, each gene has a chance to mutate according to the rate.
    # If no rate is set, a single random gene is mutated.
    #
    # @param genes [Array<Evolvable::Gene>] The collection of genes to potentially mutate
    # @return [void]
    #
    def mutate_genes(genes)
      genes_count = genes.count
      return if genes_count.zero?

      return mutate_gene_by_index(genes, rand(genes_count)) unless rate

      genes_count.times { |index| mutate_gene_by_index(genes, index) if rand <= rate }
    end

    #
    # Replaces a gene at the specified index with a new instance of the same gene class.
    #
    # @param genes [Array<Evolvable::Gene>] The collection of genes
    # @param gene_index [Integer] The index of the gene to mutate
    # @return [void]
    #
    def mutate_gene_by_index(genes, gene_index)
      genes[gene_index] = genes[gene_index].class.new
    end
  end
end
