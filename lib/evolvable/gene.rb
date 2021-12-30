# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   For evolution to be effective, an evolvable's genes must be able to influence
  #   its behavior. Evolvables are composed of genes that can be used to run simple
  #   functions or orchestrate complex interactions. The level of abstraction is up
  #   to you.
  #
  #   Defining gene classes requires encapsulating some "sample space" and returning
  #   a sample outcome when a gene attribute is accessed. For evolution to proceed
  #   in a non-random way, the same sample outcome should be returned every time
  #   a particular gene is accessed with a particular set of parameters.
  #   Memoization is a useful technique for doing just this. The
  #   [memo_wise](https://github.com/panorama-ed/memo_wise) gem may be useful for
  #   more complex memoizations.
  #
  # @example
  #   # This gene generates a random hexidecimal color code for use by evolvables.
  #
  #   require 'securerandom'
  #
  #   class ColorGene
  #     include Evolvable::Gene
  #
  #     def hex_code
  #       @hex_code ||= SecureRandom.hex(3)
  #     end
  #   end
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
