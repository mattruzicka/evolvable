class Crossover
  def initialize(growth_rate: 0.0)
    @growth_rate = growth_rate
  end

  attr_accessor :growth_rate

  def call!(population)
    assign_offspring_objects!(population)
    population
  end

  private

  def assign_offspring_objects!(population)
    offspring_genes = initialize_offspring_genes(population)
    population.objects = initialize_offspring_objects!(population, offspring_genes)
  end

  def initialize_offspring_genes(population)
    parent_genes = population.objects.map!(&:genes)
    parent_gene_couples = parent_genes.combination(2).cycle
    offspring_count = compute_offspring_count(population)
    Array.new(offspring_count) do
      p1_genes, p2_genes = parent_gene_couples.next
      offspring_genes = merge_parent_genes(p1_genes, p2_genes)
      trim_offspring_genes!(offspring_genes, p1_genes.count)
      offspring_genes
    end
  end

  def compute_offspring_count(population)
    pop_size = population.size
    return pop_size if growth_rate.zero?

    pop_size + (pop_size * growth_rate).round
  end

  def merge_parent_genes(p1_genes, p2_genes)
    Array.new(p1_genes.count) do |index|
      [p1_genes, p2_genes].sample[index]
    end
  end

  def trim_offspring_genes!(offspring_genes, parent_genes_count)
    trim_genes_count = offspring_genes.count - parent_genes_count
    return if trim_genes_count.zero?

    offspring_genes -= offspring_genes.sample(trim_genes_count)
  end

  def initialize_offspring_objects!(population, offspring_genes)
    offspring_genes.map!.with_index do |genes, i|
      population.new_evolvable(genes, population, i)
    end
  end
end
