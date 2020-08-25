# frozen_string_literal: true

module Evolvable
  module Gene
    def self.included(base)

      def base.crossover(gene_a, gene_b)
        [gene_a, gene_b].sample
      end
    end

    attr_accessor :instance,
                  :evolvable_key
  end
end
