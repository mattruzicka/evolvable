# frozen_string_literal: true

module Evolvable
  class PointCrossover
    def initialize(points_count: 1)
      @points_count = points_count
    end

    attr_accessor :points_count

    def call(population)
      population.instances = initialize_offspring(population)
      population
    end

    private

    def initialize_offspring(population)
      parent_genes = population.instances.map!(&:genes)
      parent_gene_couples = parent_genes.combination(2).cycle
      offspring = []
      population_index = 0
      loop do
        genes_1, genes_2 = parent_gene_couples.next
        crossover_genes(genes_1, genes_2).each do |genes|
          offspring << population.new_instance(genes: genes, population_index: population_index)
          population_index += 1
          return offspring if population_index == population.size
        end
      end
    end

    def crossover_genes(genes_1, genes_2)
      offspring_genes = [[], []]
      generate_ranges(genes_1.length).each do |range|
        offspring_genes.reverse!
        offspring_genes[0][range] = genes_1[range]
        offspring_genes[1][range] = genes_2[range]
      end
      offspring_genes
    end

    def generate_ranges(genes_count)
      current_point = rand(genes_count)
      range_slices = [0...current_point]
      (points_count - 1).times do
        new_point = rand(current_point...genes_count)
        break if new_point.nil?

        range_slices << (current_point...new_point)
        current_point = new_point
      end
      range_slices << (current_point..-1)
      range_slices
    end
  end
end
