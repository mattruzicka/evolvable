module Evolvable
  module HelperMethods
    def multidimensional_genes(dimensions)
      dimension_lengths = dimensions.map(&:length)
      genes_count = dimension_lengths.inject(1) { |product, c| product * c }

      genes = Array.new(genes_count) { [] }
      element_repeat_counts = compute_element_repeat_counts(dimension_lengths)
      sequence_counts = compute_sequence_counts(dimension_lengths)
      
      dimensions.each_with_index do |dimension, dim_index|
        element_count = element_repeat_counts[dim_index]
        sequence = dimension.flat_map { |e| [e] * element_count }
        dimension_sequence = sequence * sequence_counts[dim_index]
        dimension_sequence.each_with_index do |element, gene_index|
          genes[gene_index][dim_index] = element
        end
      end

      genes
    end

    def random_genes(evolvable_class, count = nil)
      gene_pool = evolvable_class::evolvable_gene_pool
      genes_count = count || evolvable_class::evolvable_genes_count
      return gene_pool.shuffle if genes_count.nil? || genes_count > gene_pool.count

      genes_names = gene_pool.sample(genes_count)
      genes_names.map! { |gn| [gn, rand] }.to_h
    end

    def weighted_random_pick(weights_hash)
      weights_sum = Random.rand(weights_hash.values.sum)
      seen_sum = 0
      weights_hash.detect { |_name, val| weights_sum <= seen_sum += val }
    end

    private

    def compute_element_repeat_counts(dimension_lengths)
      repeat_counts = Array.new(dimension_lengths.count - 1) do |n|
        right_side_counts = dimension_lengths[(n + 1)..-1]
        right_side_counts.inject(1) { |product, a| product * a }
      end
      repeat_counts << 1
      repeat_counts
    end

    def compute_sequence_counts(dimension_lengths)
      Array.new(dimension_lengths.count) do |n|
        if n.zero?
          1
        else
          right_side_counts = dimension_lengths[0...n]
          right_side_counts.inject(1) { |product, a| product * a }
        end
      end
    end
  end
end
