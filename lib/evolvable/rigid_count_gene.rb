# frozen_string_literal: true

module Evolvable
  class RigidCountGene
    include Gene

    def self.crossover(gene_a, _gene_b)
      gene_a
    end

    def initialize(count)
      @count = count
    end

    attr_reader :count
  end
end
