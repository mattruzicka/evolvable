# frozen_string_literal: true

module Evolvable
  class GeneSpace
    def self.build(config)
      return config if config.respond_to?(:new_genes)

      new(config: config)
    end

    def initialize(config: {})
      @config = normalize_config(config)
    end

    attr_reader :config

    def new_genes
      genes = []
      config.each do |_gene_key, gene_config|
        (gene_config[:count] || 1).times do
          gene = gene_config[:class].new
          genes << gene
        end
      end
      genes
    end

    private

    def normalize_config(config)
      config.each do |gene_key, gene_config|
        next unless gene_config[:type]

        gene_class = Kernel.const_get(gene_config[:type])
        gene_class.key = gene_key
        gene_config[:class] = gene_class
      end
    end
  end
end
