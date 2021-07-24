# frozen_string_literal: true

module Evolvable
  module Gene
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def key=(val)
        @key = val
      end

      def key
        @key
      end

      def combine(gene_a, gene_b)
        genes = [gene_a, gene_b]
        genes.compact!
        genes.sample
      end

      # Deprecated. Will be removed in 2.0. Use combine
      alias crossover combine
    end

    attr_accessor :instance

    def key
      self.class.key
    end
  end
end
