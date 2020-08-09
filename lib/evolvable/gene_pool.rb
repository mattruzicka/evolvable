# frozen_string_literal: true

module Evolvable
  class GenePool
    def initialize(gene_configs: {}, evolvable_genes_count: nil)
      @gene_configs = flatten_gene_configs(gene_configs)
      @evolvable_genes_count = evolvable_genes_count
    end

    attr_reader :gene_configs,
                :evolvable_genes_count

    def initialize_instance_genes
      return sample_genes(evolvable_genes_count) if evolvable_genes_count

      initialize_genes!(gene_configs.dup)
    end

    def sample_genes(sample_count)
      if sample_count > gene_configs.count
        initialize_genes!(gene_configs.cycle.first(sample_count))
      else
        initialize_genes!(gene_configs.sample(sample_count))
      end
    end

    def instance_genes_count
      @instance_genes_count ||= evolvable_genes_count || gene_configs.count
    end

    private

    def initialize_genes!(gene_configs)
      gene_configs.map! do |args|
        klass, gene_name = args
        gene = klass.new
        gene.evolvable_key = gene_name
        gene
      end
    end

    def flatten_gene_configs(configs)
      flattened = []
      configs.each do |gene_name, config|
        (config[:count] || 1).times do
          flattened << [config[:class], gene_name]
        end
      end
      flattened
    end
  end
end
