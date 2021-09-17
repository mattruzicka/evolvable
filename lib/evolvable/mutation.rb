# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Mutation serves the role of increasing genetic variation. When an evolvable
  #   undergoes a mutation, one or more of its genes are replaced by newly
  #   initialized ones. In effect, a gene mutation invokes a new random outcome
  #   from the genetic search space.
  #
  #   Mutation frequency can be configured using the `probability` and `rate`
  #   parameters.
  #
  class Mutation
    extend Forwardable

    DEFAULT_PROBABILITY = 0.03

    #
    # Initializes a new mutation object.
    #
    # Keyword arguments:
    #
    # #### probability
    # The probability that a particular instance undergoes a mutation.
    # By default, the probability is 0.03 which translates to 3%.
    # If initialized with a `rate`, the probability will be 1 which
    # means all genes _can_ undergo mutation, but actual gene mutations
    # will be subject to the given mutation rate.
    # #### rate
    # the rate at which individual genes mutate. The default rate is 0 which,
    # when combined with a non-zero `probability` (the default), means that
    # one gene for each instance that undergoes mutation will change.
    # If a rate is given, but no `probability` is given, then the `probability`
    # will bet set to 1 which always defers to the mutation rate.
    #
    # To summarize, the `probability` represents the chance of mutation on
    # the instance level and the `rate` represents the chance on the gene level.
    # The `probability` and `rate` can be any number from 0 to 1. When the
    # `probability` is 0, no mutation will ever happen. When the `probability`
    # is not 0 but the rate is 0, then any instance that undergoes mutation
    # will only receive one mutant gene. If the rate is not 0, then if an
    # instance has been chosen to undergo mutation, each of its genes will
    # mutate with a probability as defined by the `rate`.
    #
    # @example Example Initializations:
    #   Evolvable::Mutation.new # Approximately #{DEFAULT_PROBABILITY} of instances will receive one mutant gene
    #   Evolvable::Mutation.new(probability: 0.5) # Approximately 50% of instances will receive one mutant gene
    #   Evolvable::Mutation.new(rate: 0.03) # Approximately  3% of all genes in the population will mutate.
    #   Evolvable::Mutation.new(probability: 0.3, rate: 0.03) # Approximately 30% of instances will have approximately 3% of their genes mutated.
    #
    # Custom mutation objects must implement the `#call` method which accepts the population as the first object.
    #
    def initialize(probability: nil, rate: nil)
      @probability = probability || (rate ? 1 : DEFAULT_PROBABILITY)
      @rate = rate
    end

    attr_accessor :probability,
                  :rate

    def call(population)
      mutate_evolvables(population.evolvables) unless probability.zero?
      population
    end

    def mutate_evolvables(evolvables)
      evolvables.each do |evolvable|
        next unless rand <= probability

        evolvable.genome.each { |_key, config| mutate_genes(config[:genes]) }
      end
    end

    private

    def mutate_genes(genes)
      genes_count = genes.count
      return if genes_count.zero?

      return mutate_gene_by_index(genes, rand(genes_count)) unless rate

      genes_count.times { |index| mutate_gene_by_index(genes, index) if rand <= rate }
    end

    def mutate_gene_by_index(genes, gene_index)
      genes[gene_index] = genes[gene_index].class.new
    end
  end
end
