# frozen_string_literal: true

module Evolvable
  class SearchSpace
    def self.build(config, evolvable_class = nil)
      return config if config.respond_to?(:new_genome)

      new(config: config, evolvable_class: evolvable_class)
    end

    def initialize(config: {}, evolvable_class: nil)
      @evolvable_class = evolvable_class
      @config = normalize_config(config)
    end

    attr_reader :config

    def new_genome
      Genome.new(config: new_genome_config)
    end

    private

    def normalize_config(config)
      case config
      when Hash
        normalize_hash_config(config)
      when Array
        if config.first.is_a?(Array)
          build_config_from_2d_array(config)
        else
          merge_config_with_array({}, config)
        end
      end
    end

    def normalize_hash_config(config)
      config.each do |gene_key, gene_config|
        next unless gene_config[:type]

        gene_class = lookup_gene_class(gene_config[:type])
        gene_class.key = gene_key
        gene_config[:class] = gene_class
      end
    end

    def build_config_from_2d_array(array_config)
      config = {}
      array_config.each { |array| merge_config_with_array(config, array) }
      config
    end

    def merge_config_with_array(config, gene_array)
      gene_key, gene_class, count = extract_array_configs(gene_array)
      gene_class.key = gene_key
      config[gene_key] = { class: gene_class, count: count }
      config
    end

    def extract_array_configs(gene_array)
      first_item = gene_array.first
      return extract_array_with_key_configs(gene_array) if first_item.is_a?(Symbol)

      gene_class = lookup_gene_class(first_item)
      _type, count = gene_array
      [gene_class, gene_class, count]
    rescue NameError
      extract_array_with_key_configs(gene_array)
    end

    def extract_array_with_key_configs(gene_array)
      gene_key, type, count = gene_array
      gene_class = lookup_gene_class(type)
      [gene_key, gene_class, count]
    end

    def lookup_gene_class(class_name)
      return class_name if class_name.is_a?(Class)

      (@evolvable_class || Object).const_get(class_name)
    end

    def new_genome_config
      genome_config = {}
      config.each do |gene_key, gene_config|
        genome_config[gene_key] = new_gene_config(gene_config)
      end
      genome_config
    end

    def new_gene_config(gene_config)
      count_gene = init_count_gene(gene_config)
      gene_class = gene_config[:class]
      genes = Array.new(count_gene.count) { gene_class.new }
      { count_gene: count_gene, genes: genes }
    end

    def init_count_gene(gene_config)
      min = gene_config[:min_count]
      max = gene_config[:max_count]
      return init_min_max_count_gene(min, max) if min || max

      count = gene_config[:count] || 1
      case count
      when Numeric
        RigidCountGene.new(count)
      when Range
        CountGene.new(range: count)
      when String
        Kernel.const_get(gene_config[:count]).new
      when Class
        gene_config[:count].new
      end
    end

    def init_min_max_count_gene(min, max)
      min ||= 1
      max ||= min * 10
      CountGene.new(range: min..max)
    end
  end

  # Deprecated. Will be removed in 2.0
  # use Evolvable::EqualizeGoal instead
  class GeneSpace < SearchSpace; end
end
