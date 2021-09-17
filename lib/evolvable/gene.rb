# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   For evolution to be effective, an evolvable's genes must be able to influence
  #   its behavior. Evovlable instances are composed of genes which can be used
  #   to implement simple functions or orchestrate complex interactions.
  #
  #   Defining gene classes requires encapsulating some "sample space" and returning
  #   a sample outcome when a gene attribute is accessed. For evolution to proceed
  #   in a non-random way, the same sample outcome should be returned every time
  #   a particular gene is accessed with a particular set of parameters.
  #   Memoization is a useful technique for doing just this. You may find
  #   the [memo_wise](https://github.com/panorama-ed/memo_wise) gem useful.
  #
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

      #
      # @deprecated
      #   Will be removed in 2.0
      #   Use {#combine}
      #
      alias crossover combine
    end

    attr_accessor :evolvable

    def key
      self.class.key
    end
  end
end
