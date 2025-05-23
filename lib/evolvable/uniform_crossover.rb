# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Chooses genes independently at each position, selecting randomly from either
  #   parent with equal probability. No segments are preserved—each gene is treated
  #   in isolation.
  #
  #   Best for:
  #   - Problems where gene order doesn't matter
  #   - High genetic diversity and exploration
  #   - Complex interdependencies across traits
  #
  #   Uniform crossover is especially effective when good traits are scattered across the genome.
  #
  #   Set your population to use this strategy during initialization with:
  #
  #   ```ruby
  #   population = MyEvolvable.new_population(
  #     combination: Evolvable::UniformCrossover.new
  #   )
  #   ```
  #
  #   Or update an existing population:
  #
  #   ```ruby
  #   population.combination = Evolvable::UniformCrossover.new
  #   ```
  #
  class UniformCrossover
    def call(population)
      population.evolvables = new_evolvables(population, population.size)
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
      genome_1, genome_2 = genome_pair
      genome_1.each do |gene_key, gene_config_1|
        gene_config_2 = genome_2.config[gene_key]
        count_gene = [gene_config_1, gene_config_2].sample[:count_gene]
        genes = crossover_genes(count_gene.count, gene_config_1, gene_config_2)
        new_config[gene_key] = { count_gene: count_gene, genes: genes }
      end
      Genome.new(config: new_config)
    end

    def crossover_genes(count, gene_config_1, gene_config_2)
      gene_arrays = [gene_config_1[:genes], gene_config_2[:genes]]
      Array.new(count) do |index|
        gene_arrays.shuffle!.detect { |genes| genes[index] }
      end
    end
  end
end
