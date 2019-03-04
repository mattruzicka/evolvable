class Crossover
  def call(parent_genes, offspring_count)
    parent_gene_couples = parent_genes.combination(2).cycle
    Array.new(offspring_count) do
      p1_genes, p2_genes = parent_gene_couples.next
      p1_genes.merge(p2_genes) { |_k, p1_val, p2_val| [p1_val, p2_val].sample }
      offspring_genes = merge_parent_genes(p1_genes, p2_genes)
      trim_offspring_genes!(offspring_genes, p1_genes.count)
      offspring_genes
    end
  end

  private

  def merge_parent_genes(p1_genes, p2_genes)
    p1_genes.merge(p2_genes) { |_k, p1_val, p2_val| [p1_val, p2_val].sample }
  end

  def trim_offspring_genes!(offspring_genes, parent_genes_count)
    trim_genes_count = offspring_genes.count - parent_genes_count
    return if trim_genes_count.zero?

    offspring_genes.keys.sample(trim_genes_count).each do |name|
      offspring_genes.delete(name)
    end
  end
end
