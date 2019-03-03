module Evolvable
  class Mutation
    extend Forwardable

    def initialize(rate: 0.03)
      @rate = rate
    end

    def_delegators :@evolvable_class,
                   :evolvable_genes_count,
                   :evolvable_gene_pool_size,
                   :evolvable_random_genes

    def call!(individuals)
      @evolvable_class = individuals.first.class
      mutations_count = find_mutations_count(individuals)
      return if mutations_count.zero?

      mutant_genes = generate_mutant_genes(mutations_count)
      individual_mutations_count = mutations_count / individuals.count
      individual_mutations_count = 1 if individual_mutations_count.zero?

      mutant_genes.each_slice(individual_mutations_count).with_index do |m_genes, index|
        individual = individuals[index] || individuals.sample
        genes = individual.genes
        genes.merge!(m_genes.to_h)
        rm_genes_count = genes.count - evolvable_genes_count
        genes.keys.sample(rm_genes_count).each { |key| genes.delete(key) }
      end
    end

    private

    def find_mutations_count(individuals)
      return 0 if @rate.zero?

      count = (individuals.count * evolvable_genes_count * @rate)
      return count.to_i if count >= 1

      rand <= count ? 1 : 0
    end

    def generate_mutant_genes(mutations_count)
      gene_pool_size = evolvable_gene_pool_size
      mutant_genes = []
      while mutant_genes.count < mutations_count
        genes_count = [gene_pool_size, mutations_count - mutant_genes.count].min
        mutant_genes.concat evolvable_random_genes(genes_count).to_a
      end
      mutant_genes
    end
  end
end
