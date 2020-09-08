# frozen_string_literal: true

module Evolvable
  class Mutation
    extend Forwardable

    def initialize(probability: nil, rate: nil)
      @probability = probability || (rate ? 1 : 0.03)
      @rate = rate || 0
    end

    attr_accessor :probability,
                  :rate

    def call(population)
      return population if probability.zero?

      population.instances.each do |instance|
        mutate_instance(instance) if rand <= probability
      end
      population
    end

    private

    def mutate_instance(instance)
      genes_count = instance.genes.count
      return if genes_count.zero?

      return mutate_gene(instance, rand(genes_count)) if rate.zero?

      genes_count.times { |index| mutate_gene(instance, index) if rand <= rate }
    end

    def mutate_gene(instance, gene_index)
      gene = instance.genes[gene_index]
      mutant_gene = gene.class.new
      mutant_gene.key = gene.key
      instance.genes[gene_index] = mutant_gene
    end
  end
end
