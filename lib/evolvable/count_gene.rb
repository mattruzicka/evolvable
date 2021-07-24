# frozen_string_literal: true

module Evolvable
  class CountGene
    include Gene

    class << self
      def combine(gene_a, gene_b)
        min = gene_a.min_count
        max = gene_a.max_count
        count = combination.call(gene_a, gene_b).clamp(min, max)
        new(range: gene_a.range, count: count)
      end

      LAMBDAS = [->(a, b) { [a, b].sample.count + rand(-1..1) },
                 ->(a, b) { a.count + b.count / 2 }].freeze

      def combination
        LAMBDAS.sample
      end
    end

    def initialize(range:, count: nil)
      @range = range
      @count = count
    end

    attr_reader :range

    def count
      @count ||= rand(@range)
    end

    def min_count
      @range.min
    end

    def max_count
      @range.max
    end
  end
end
