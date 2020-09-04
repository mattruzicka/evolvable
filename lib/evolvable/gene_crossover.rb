# frozen_string_literal: true

module Evolvable
  class GeneCrossover
    def call(population)
      population.instances = initialize_offspring(population)
      population
    end

    private

    def initialize_offspring(population)
      parent_genes = population.instances.map!(&:genes)
      parent_gene_couples = parent_genes.combination(2).cycle
      Array.new(population.size) do |index|
        genes_1, genes_2 = parent_gene_couples.next
        genes = crossover_genes(genes_1, genes_2)
        population.new_evolvable(genes: genes, evolvable_index: index)
      end
    end

    def crossover_genes(genes_1, genes_2)
      genes_1.zip(genes_2).map! do |gene_a, gene_b|
        gene_a.class.crossover(gene_a, gene_b)
      end
    end
  end
end
