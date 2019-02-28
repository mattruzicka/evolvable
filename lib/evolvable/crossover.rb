class Crossover
  def call(parent_genes, offspring_count)
    parent_offspring_count = offspring_count / 2
    parent_gene_arrays = parent_genes.map(&:to_a)
    paired_parent_arrays = parent_gene_arrays.combination(2).cycle
    Array.new(offspring_count).each do
      p1_gene_array, p2_gene_array = paired_parent_arrays.next
      (p1_gene_array | p2_gene_array).sample(p1_gene_array.count).to_h
    end
	end
end
