# frozen_string_literal: true

module Evolvable
  class Mutation
    extend Forwardable

    def initialize(rate: 0.03)
      @rate = rate
    end

    attr_accessor :rate

    def call!(population)
      objects = population.objects
      gene_pool = population.gene_pool
      mutations_count = find_mutations_count(objects, gene_pool)
      mutate_object_genes!(objects, gene_pool, mutations_count)
      population
    end

    private

    def mutate_object_genes!(objects, gene_pool, mutations_count)
      return if mutations_count.zero?

      mutant_genes = gene_pool.sample_genes(mutations_count)
      gene_index_range = 0...gene_pool.object_genes_count

      mutant_genes.each do |mutant_gene|
        object = objects.sample
        object.genes[rand(gene_index_range)] = mutant_gene
      end
    end

    def find_mutations_count(objects, gene_pool)
      return 0 if @rate.zero?

      count = (objects.count * gene_pool.object_genes_count * @rate)
      return count.to_i if count >= 1

      rand <= count ? 1 : 0
    end
  end
end
