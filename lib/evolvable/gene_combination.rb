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
  #   This implementation enables individual gene types to define their own
  #   combination behaviors through the Gene.combine class method, giving you
  #   fine-grained control over how different gene types are combined.
  #
  # @example
  #   # Use default gene combination
  #   population = MyEvolvable.new_population(
  #     combination: Evolvable::GeneCombination.new
  #   )
  #
  #   population.evolve
  #
  class GeneCombination
    #
    # Performs the combination operation on the population.
    # Creates new evolvables by combining parent genomes.
    #
    # @param population [Evolvable::Population] The population to perform combination on
    # @return [Evolvable::Population] The population with new evolvables
    #
    def call(population)
      new_evolvables(population, population.size)
      population
    end

    #
    # Creates new evolvable instances by combining parent genomes.
    # For each new evolvable, selects parent genomes and combines them.
    #
    # @param population [Evolvable::Population] The population containing parent evolvables
    # @param count [Integer] The number of new evolvables to create
    # @return [Array<Evolvable>] The newly created evolvables
    #
    def new_evolvables(population, count)
      parent_genome_cycle = population.new_parent_genome_cycle
      Array.new(count) do
        genome_1, genome_2 = parent_genome_cycle.next
        genome = combine_genomes(genome_1, genome_2)
        population.new_evolvable(genome: genome)
      end
    end

    #
    # Combines two parent genomes to create a new genome.
    # For each gene key, combines the count genes and individual genes.
    #
    # @param genome_1 [Evolvable::Genome] The first parent genome
    # @param genome_2 [Evolvable::Genome] The second parent genome
    # @return [Evolvable::Genome] A new genome resulting from the combination
    #
    def combine_genomes(genome_1, genome_2)
      new_config = {}
      genome_1.each do |gene_key, gene_config_1|
        gene_config_2 = genome_2.config[gene_key]
        count_gene = combine_count_genes(gene_config_1, gene_config_2)
        genes = combine_genes(count_gene.count, gene_config_1, gene_config_2)
        new_config[gene_key] = { count_gene: count_gene, genes: genes }
      end
      Genome.new(config: new_config)
    end

    private

    #
    # Combines two count genes to create a new count gene.
    # Delegates to the count gene class's combine method.
    #
    # @param gene_config_1 [Hash] Configuration for the first gene group
    # @param gene_config_2 [Hash] Configuration for the second gene group
    # @return [Evolvable::CountGene, Evolvable::RigidCountGene] A new count gene
    #
    def combine_count_genes(gene_config_1, gene_config_2)
      count_gene_1 = gene_config_1[:count_gene]
      count_gene_2 = gene_config_2[:count_gene]
      count_gene_1.class.combine(count_gene_1, count_gene_2)
    end

    #
    # Combines genes from two parent gene configurations.
    # For each gene position, if both genes exist, uses the gene class's
    # combine method to create a new gene. Otherwise, uses the existing
    # gene or creates a new one.
    #
    # @param count [Integer] The number of genes to create
    # @param gene_config_1 [Hash] Configuration for the first gene group
    # @param gene_config_2 [Hash] Configuration for the second gene group
    # @return [Array<Evolvable::Gene>] An array of combined genes
    #
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
