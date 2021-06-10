# frozen_string_literal: true

module Evolvable
  class GeneCrossover
    def call(population)
      population.instances = initialize_offspring(population)
      population
    end

    private

    def initialize_offspring(population)
      genomes = population.instances.map!(&:genome).shuffle!
      genomes_pairs = genomes.combination(2).cycle
      Array.new(population.size) do
        genome = build_genome(genomes_pairs.next)
        population.new_instance(genome: genome)
      end
    end

    def build_genome(genome_pair)
      new_config = {}
      genome_1, genome_2 = genome_pair.shuffle!
      genome_1.each do |gene_key, gene_config_1|
        gene_config_2 = genome_2.config[gene_key]
        count_gene = crossover_count_genes(gene_config_1, gene_config_2)
        genes = crossover_genes(count_gene.count, gene_config_1, gene_config_2)
        new_config[gene_key] = { count_gene: count_gene, genes: genes }
      end
      Genome.new(config: new_config)
    end

    def crossover_count_genes(gene_config_1, gene_config_2)
      count_gene_1 = gene_config_1[:count_gene]
      count_gene_2 = gene_config_2[:count_gene]
      count_gene_1.class.crossover(count_gene_1, count_gene_2)
    end

    def crossover_genes(count, gene_config_1, gene_config_2)
      genes_1 = gene_config_1[:genes]
      genes_2 = gene_config_2[:genes]
      gene_class = genes_1.first.class
      Array.new(count) do |index|
        gene_a = genes_1[index]
        gene_b = genes_2[index]
        gene_class.crossover(gene_a, gene_b) || gene_class.new
      end
    end
  end
end
