# frozen_string_literal: true

module Evolvable
  class Mutation
    extend Forwardable

    def initialize(rate: 0.03)
      @rate = rate
    end

    attr_accessor :rate

    def call!(population)
      return population if rate.zero?

      instances = population.instances
      gene_pool = population.gene_pool
      mutations_count = find_mutations_count(instances, gene_pool)
      mutate_instance_genes!(instances, gene_pool, mutations_count)
      population
    end

    private

    def mutate_instance_genes!(instances, gene_pool, mutations_count)
      return if mutations_count.zero?

      mutant_genes = gene_pool.sample_genes(mutations_count)
      gene_index_range = 0...gene_pool.instance_genes_count

      mutant_genes.each do |mutant_gene|
        instance = instances.sample
        instance.genes[rand(gene_index_range)] = mutant_gene
      end
    end

    def find_mutations_count(instances, gene_pool)
      count = (instances.count * gene_pool.instance_genes_count * rate)
      return count.to_i if count >= 1

      rand <= count ? 1 : 0
    end
  end
end
