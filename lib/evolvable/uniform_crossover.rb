# frozen_string_literal: true

module Evolvable
  class UniformCrossover
    def call(population)
      population.instances = new_instances(population, population.size)
      population
    end

    def new_instances(population, count)
      parent_genome_cycle = population.new_parent_genome_cycle
      Array.new(count) do
        genome = build_genome(parent_genome_cycle.next)
        population.new_instance(genome: genome)
      end
    end

    private

    def build_genome(genome_pair)
      new_config = {}
      genome_1, genome_2 = genome_pair.shuffle!
      genome_1.each do |gene_key, gene_config_1|
        count_gene = gene_config_1[:count_gene]
        genes = crossover_genes(count_gene.count, gene_config_1, genome_2.config[gene_key])
        new_config[gene_key] = { count_gene: count_gene, genes: genes }
      end
      Genome.new(config: new_config)
    end

    def crossover_genes(count, gene_config_1, gene_config_2)
      gene_arrays = [gene_config_1[:genes], gene_config_2[:genes]]
      Array.new(count) do |index|
        genes = gene_arrays.sample
        genes[index] || gene_arrays.detect { |a| a != genes }[index]
      end
    end
  end
end
