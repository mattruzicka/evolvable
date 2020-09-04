# frozen_string_literal: true

module Evolvable
  class UniformCrossover
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
        genes = genes_1.zip(genes_2).map!(&:sample)
        population.new_evolvable(genes: genes, evolvable_index: index)
      end
    end
  end
end
