# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Combination generates new evolvable instances by combining the genes of selected instances.
  #   You can think of it as a mixing of parent genes from one generation to
  #   produce the next generation.
  #
  #   You may choose from a selection of combination objects or implement your own.
  #   The default combination object is `Evolvable::GeneCombination`.
  #
  # Custom crossover objects must implement the `#call` method which accepts
  # the population as the first object.
  # Enables gene types to define combination behaviors.
  #
  # Each gene class can implement a unique behavior for
  # combination by overriding the following default implementation
  # which mirrors the behavior of `Evolvable::UniformCrossover`
  #
  class GeneCombination
    def call(population)
      new_evolvables(population, population.size)
      population
    end

    def new_evolvables(population, count)
      parent_genome_cycle = population.new_parent_genome_cycle
      Array.new(count) do
        genome = build_genome(parent_genome_cycle.next)
        population.new_evolvable(genome: genome)
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
        if gene_a && gene_b
          gene_class.combine(gene_a, gene_b)
        else
          gene_a || gene_b || gene_class.new
        end
      end
    end
  end
end
