# frozen_string_literal: true

module Evolvable
  #
  # The CountGene class handles the dynamic count of genes in evolvable instances.
  # When a gene is defined with a range for `count:` (e.g., `count: 2..8`), a CountGene
  # is created to manage this count, allowing the number of genes to change over
  # successive generations.
  #
  # @example Define a melody with a variable number of notes (4 to 16)
  #   class Melody
  #     include Evolvable
  #
  #     gene :notes, type: NoteGene, count: 4..16
  #
  #     # The actual number of notes can change during evolution
  #     def play
  #       puts "Playing melody with #{notes.count} notes"
  #     end
  #   end
  #
  class CountGene
    include Gene

    class << self
      #
      # Combines two count genes to produce a new count gene.
      # The combination strategy is randomly selected from LAMBDAS.
      #
      # @param gene_a [CountGene] The first count gene
      # @param gene_b [CountGene] The second count gene
      # @return [CountGene] A new count gene with a combined count value
      #
      def combine(gene_a, gene_b)
        min = gene_a.min_count
        max = gene_a.max_count
        count = combination.call(gene_a, gene_b).clamp(min, max)
        new(range: gene_a.range, count: count)
      end

      #
      # Available strategies for combining count genes.
      # These lambdas determine how two count genes are merged during evolution.
      #
      # 1. Random selection with slight mutation (-1, 0, or +1)
      # 2. Average of the two counts
      #
      LAMBDAS = [->(a, b) { [a, b].sample.count + rand(-1..1) },
                 ->(a, b) { a.count + b.count / 2 }].freeze

      #
      # Selects a random combination strategy from LAMBDAS.
      #
      # @return [Proc] A lambda function for combining two count genes
      #
      def combination
        LAMBDAS.sample
      end
    end

    #
    # Initializes a new CountGene instance.
    #
    # @param range [Range] The valid range for the count value
    # @param count [Integer, nil] Optional initial count value, randomly selected from range if nil
    #
    def initialize(range:, count: nil)
      @range = range
      @count = count
    end

    #
    # The valid range for the count value.
    #
    # @return [Range] The range of possible count values
    #
    attr_reader :range

    #
    # Returns the current count value.
    # If not already set, randomly selects a value from the range.
    #
    # @return [Integer] The number of genes to create
    #
    def count
      @count ||= rand(@range)
    end

    #
    # The minimum allowed count value.
    #
    # @return [Integer] The minimum value from the range
    #
    def min_count
      @range.min
    end

    #
    # The maximum allowed count value.
    #
    # @return [Integer] The maximum value from the range
    #
    def max_count
      @range.max
    end
  end
end
