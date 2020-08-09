# frozen_string_literal: true

module Evolvable
  module Gene
    def self.included(base)

      def base.crossover(gene_1, gene_2)
        [gene_1, gene_2].sample
      end
    end

    attr_accessor :evolvable_key
  end
end
