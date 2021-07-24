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

      def crossover(gene_a, gene_b)
        genes = [gene_a, gene_b]
        genes.compact!
        genes.sample
      end
    end

    attr_accessor :instance

    def key
      self.class.key
    end
  end
end
