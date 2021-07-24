# frozen_string_literal: true

module Evolvable
  class GeneCombination
    def call(population)
      new_instances(population, population.size)
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
        gene_config_2 = genome_2.config[gene_key]
        count_gene = combine_count_genes(gene_config_1, gene_config_2)
        genes = combine_genes(count_gene.count, gene_config_1, gene_config_2)
        new_config[gene_key] = { count_gene: count_gene, genes: genes }
      end
      Genome.new(config: new_config)
    end

    def combine_count_genes(gene_config_1, gene_config_2)
      count_gene_1 = gene_config_1[:count_gene]
      count_gene_2 = gene_config_2[:count_gene]
      count_gene_1.class.combine(count_gene_1, count_gene_2)
    end

    def combine_genes(count, gene_config_1, gene_config_2)
      genes_1 = gene_config_1[:genes]
      genes_2 = gene_config_2[:genes]
      first_gene = genes_1.first || genes_2.first
      return [] unless first_gene

      gene_class = first_gene.class
      Array.new(count) do |index|
        gene_a = genes_1[index]
        gene_b = genes_2[index]
        gene_class.combine(gene_a, gene_b) || gene_class.new
      end
    end
  end
end
