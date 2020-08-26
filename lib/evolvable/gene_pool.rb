# frozen_string_literal: true

module Evolvable
  class GenePool
    def initialize(gene_configs: {})
      @gene_configs = gene_configs
    end

    attr_reader :gene_configs

    def initialize_instance_genes
      genes = []
      gene_configs.each do |gene_name, config|
        (config[:count] || 1).times do
          gene = config[:class].new
          gene.evolvable_key = gene_name
          genes << gene
        end
      end
      genes
    end
  end
end
