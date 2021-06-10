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
      return population if probability.zero?

      population.instances.each do |instance|
        next unless mutate_genes?

        instance.genome.each_gene_config { |gc| mutate_genes(gc[:genes]) }
      end
      population
    end

    private

    def mutate_genes?
      case probability
      when 1
        true
      when 0
        false
      else
        rand <= probability
      end
    end

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
