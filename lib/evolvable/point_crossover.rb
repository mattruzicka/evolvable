# frozen_string_literal: true

module Evolvable
  class PointCrossover
    def initialize(points_count: 1)
      @points_count = points_count
    end

    attr_accessor :points_count

    def call(population)
      population.evolvables = new_evolvables(population, population.size)
      population
    end

    def new_evolvables(population, count)
      parent_genome_cycle = population.new_parent_genome_cycle
      evolvables = []
      loop do
        genome_1, genome_2 = parent_genome_cycle.next
        crossover_genomes(genome_1, genome_2).each do |genome|
          evolvable = population.new_evolvable(genome: genome)
          evolvables << evolvable
          return evolvables if evolvable.generation_index == count
        end
      end
    end

    private

    def crossover_genomes(genome_1, genome_2)
      genome_1 = genome_1.dup
      genome_2 = genome_2.dup
      genome_1.each do |gene_key, gene_config_1|
        gene_config_2 = genome_2.config[gene_key]
        genes_1 = gene_config_1[:genes]
        genes_2 = gene_config_2[:genes]
        crossover_genes!(genes_1, genes_2)
      end
      [genome_1, genome_2]
    end

    def crossover_genes!(genes_1, genes_2)
      generate_ranges(genes_1.length).each do |range|
        genes_2_range_values = genes_2[range]
        genes_2[range] = genes_1[range]
        genes_1[range] = genes_2_range_values
      end
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
