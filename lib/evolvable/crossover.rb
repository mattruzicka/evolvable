# frozen_string_literal: true

module Evolvable
  class Crossover
    def initialize(growth_rate: 0.0)
      @growth_rate = growth_rate
    end

    attr_accessor :growth_rate

    def call!(population)
      population.instances = initialize_offspring(population)
      population
    end

    private

    def initialize_offspring(population)
      parent_genes = population.instances.map!(&:genes)
      parent_gene_couples = parent_genes.combination(2).cycle
      offspring_count = compute_offspring_count(population)
      Array.new(offspring_count) do |index|
        genes_1, genes_2 = parent_gene_couples.next
        genes = crossover_genes(genes_1, genes_2)
        population.new_evolvable(genes: genes, evolvable_index: index)
      end
    end

    def compute_offspring_count(population)
      pop_size = population.size
      return pop_size if growth_rate.zero?

      pop_size + (pop_size * growth_rate).round
    end

    def crossover_genes(genes_1, genes_2)
      genes_1.zip(genes_2).map! do |gene_a, gene_b|
        gene_a.class.crossover(gene_a, gene_b)
      end
    end
  end
end
