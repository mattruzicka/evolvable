# frozen_string_literal: true

module Evolvable
  class GeneSpace
    def initialize(evolvable_genes: {})
      @evolvable_genes = evolvable_genes
    end

    attr_reader :evolvable_genes

    def initialize_genes
      genes = []
      evolvable_genes.each do |gene_name, config|
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
