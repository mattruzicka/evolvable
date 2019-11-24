# frozen_string_literal: true

module Evolvable
  class GenePool
    def initialize(gene_configs: {}, evolvable_genes_count: nil)
      @gene_configs = gene_configs
      @evolvable_genes_count = evolvable_genes_count
    end

    attr_reader :gene_configs,
                :evolvable_genes_count

    def initialize_object_genes
      return sample_genes(evolvable_genes_count) if evolvable_genes_count

      initialize_genes!(gene_args.dup)
    end

    def sample_genes(sample_count)
      if sample_count > gene_args.count
        initialize_genes!(gene_args.cycle.first(sample_count))
      else
        initialize_genes!(gene_args.sample(sample_count))
      end
    end

    def object_genes_count
      @object_genes_count ||= evolvable_genes_count || gene_args.count
    end

    private

    def initialize_genes!(gene_args)
      gene_args.map! do |args|
        klass, gene_name = args
        gene = klass.new_evolvable
        gene.evolvable_key = gene_name
        gene
      end
    end

    def gene_args
      @gene_args ||= flatten_gene_args
    end

    def flatten_gene_args
      configs = []
      gene_configs.each do |gene_name, config|
        (config[:count] || 1).times do
          configs << [config[:class], gene_name]
        end
      end
      configs
    end
  end
end
