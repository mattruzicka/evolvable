# frozen_string_literal: true

class Crossover
  def initialize(growth_rate: 0.0)
    @growth_rate = growth_rate
  end

  attr_accessor :growth_rate

  def call!(population)
    assign_offspring_instances!(population)
    population
  end

  private

  def assign_offspring_instances!(population)
    offspring_genes = initialize_offspring_genes(population)
    population.instances = initialize_offspring_instances!(population, offspring_genes)
  end

  def initialize_offspring_genes(population)
    parent_genes = population.instances.map!(&:genes)
    parent_gene_couples = parent_genes.combination(2).cycle
    offspring_count = compute_offspring_count(population)
    Array.new(offspring_count) do
      genes_1, genes_2 = parent_gene_couples.next
      offspring_genes = crossover_genes(genes_1, genes_2)
      trim_offspring_genes!(offspring_genes, genes_1.count)
      offspring_genes
    end
  end

  def compute_offspring_count(population)
    pop_size = population.size
    return pop_size if growth_rate.zero?

    pop_size + (pop_size * growth_rate).round
  end

  def crossover_genes(genes_1, genes_2)
    genes_1.lazy.zip(genes_2).map do |gene_a, gene_b|
      gene_a.class.crossover(gene_a, gene_b)
    end.to_a
  end

  def trim_offspring_genes!(offspring_genes, parent_genes_count)
    trim_genes_count = offspring_genes.count - parent_genes_count
    return if trim_genes_count.zero?

    offspring_genes -= offspring_genes.sample(trim_genes_count)
  end

  def initialize_offspring_instances!(population, offspring_genes)
    offspring_genes.map!.with_index do |genes, i|
      population.new_evolvable(genes, population, i)
    end
  end
end
