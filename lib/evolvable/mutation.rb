# frozen_string_literal: true

module Evolvable
  class Mutation
    extend Forwardable

    def initialize(probability: nil, rate: nil)
      @probability = probability || (rate ? 1 : 0.03)
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
