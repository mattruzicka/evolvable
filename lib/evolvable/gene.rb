# frozen_string_literal: true

module Evolvable
  module Gene
    def self.included(base)
      def base.key=(val)
        @key = val
      end

      def base.key
        @key
      end

      def base.crossover(gene_a, gene_b)
        [gene_a, gene_b].sample
      end
    end

    attr_accessor :instance

    def key
      self.class.key
    end
  end
end
