# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   UniformCrossover randomly selects genes from either parent with equal probability
  #   for each gene position. Unlike point crossover, there are no "chunks" of genes preserved
  #   from either parent - each gene is chosen independently.
  #
  #   This strategy:
  #   - Provides maximum mixing of genetic material
  #   - Better handles problems where gene ordering isn't important
  #   - Often performs well on problems with complex interdependencies
  #
  #   Uniform crossover is particularly effective when good solutions have traits that are
  #   widely distributed throughout the genome rather than clustered together.
  #
  #   Configuration:
  #   ```ruby
  #   population = MyEvolvable.new_population(
  #     combination: Evolvable::UniformCrossover.new
  #   )
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
