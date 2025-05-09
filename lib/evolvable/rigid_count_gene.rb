# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   The RigidCountGene class manages fixed gene counts in evolvable instances.
  #   Unlike CountGene, the RigidCountGene maintains a constant number of genes
  #   that doesn't change during evolution. This is used when a gene is defined
  #   with a fixed integer for `count:` (e.g., `count: 5`).
  #
  # @example
  #   # Define a chord with exactly 4 notes
  #   class Chord
  #     include Evolvable
  #
  #     gene :notes, type: NoteGene, count: 4
  #
  #     # The number of notes will always be 4, never changing during evolution
  #     def play
  #       puts "Playing chord with #{notes.count} notes"
  #     end
  #   end
  #
  class RigidCountGene
    include Gene

    #
    # Combines two rigid count genes by always returning the first one.
    # This ensures the count remains constant during evolution.
    #
    # @param gene_a [RigidCountGene] The first rigid count gene
    # @param _gene_b [RigidCountGene] The second rigid count gene (unused)
    # @return [RigidCountGene] The first count gene unchanged
    #
    def self.combine(gene_a, _gene_b)
      gene_a
    end

    #
    # Initializes a new RigidCountGene with a fixed count.
    #
    # @param count [Integer] The fixed number of genes to create
    #
    def initialize(count)
      @count = count
    end

    #
    # The fixed number of genes to create.
    #
    # @return [Integer] The gene count
    #
    attr_reader :count
  end
end
