class Crossover
  def call(parent_genes, offspring_count)
    parent_gene_couples = parent_genes.combination(2).cycle
    Array.new(offspring_count) do
      p1_genes, p2_genes = parent_gene_couples.next
      offspring_genes = merge_parent_genes(p1_genes, p2_genes)
      trim_offspring_genes!(offspring_genes, p1_genes.count)
      offspring_genes
    end
  end

  def inspect
    "#<#{self.class.name} #{as_json.map { |a| a.join(': ') }.join(', ')} >"
  end

  def as_json
    { type: self.class.name }
  end

  private

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
end
