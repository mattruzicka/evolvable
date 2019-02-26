module Evolvable
	class Mutation
    extend Forwardable

		def initialize(mutation_rate: 0.1)
      @mutation_rate = mutation_rate
		end

    def_delegator :@evolvable_class,
                  :evolvable_genes_count,
                  :evolvable_gene_pool

    def call!(individuals)
      @evolvable_class = individuals.first.class
      individual_genes_count = evolvable_genes_count
      individual_mutation_count = (individual_genes_count * @mutation_rate).to_i
      population_mutation_count = individual_mutation_count * individuals.count
      mutant_genes = generate_mutant_genes(population_mutation_count)
      mutant_genes.each_slice(individual_mutation_count).with_index do |m_genes, i|
        genes = individuals[i].genes
        genes.merge!(m_genes)
        rm_genes_count = genes.count - individual_genes_count
        genes.keys.sample(rm_genes_count).each { |key| genes.delete(key) }
      end
    end

    private

    def generate_mutant_genes(mutation_count, total_genes_count)
      gene_pool_size = evolvable_gene_pool.size
      mutant_genes = []
      while mutant_genes.count < mutation_count
        mutants_count = [gene_pool_size, mutation_count - mutant_genes.count].min
        mutant_genes.concat Evolvable.random_genes(@evolvable_class, mutants_count)
      end
      mutant_genes
    end
	end
end
