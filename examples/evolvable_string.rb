require './examples/evolvable_string/char_gene'

class EvolvableString
  include Evolvable

  TARGET_STRING = 'supercalifragilisticexpialidocious'

  def self.gene_space
    { char_genes: { type: 'CharGene', count: TARGET_STRING.length } }
  end

  def self.before_evolution(population)
    best_instance = population.best_instance
    puts "#{best_instance} | #{best_instance.value} matches | Generation #{population.evolutions_count}"
  end

  def to_s
    find_genes(:char_genes).join
  end

  def value
    @value ||= compute_value
  end

  def compute_value
    value = 0
    find_genes(:char_genes).each_with_index do |gene, index|
      value += 1 if gene.to_s == TARGET_STRING[index]
    end
    value
  end
end
