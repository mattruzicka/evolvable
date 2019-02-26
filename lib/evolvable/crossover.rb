class Crossover
	def call(parent_genes, offspring_count)
    parent_offspring_count = offspring_count / 2
    paired_genes = parent_genes.combination(2).cycle
    Array.new(offspring_count).each do
    	p1_genes, p2_genes = paired_genes.next
      (p1_genes | p2_genes).sample(p1_genes.count)
    end
	end
end
