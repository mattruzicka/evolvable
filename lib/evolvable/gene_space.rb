# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   The gene space defines the genetic structure of evolvable classes - a blueprint
  #   for creating and managing genes.
  #
  #   **Two Key Gene Count Types**
  #
  #   1. **Fixed Count**: When you specify a single number or default
  #
  #   ```ruby
  #   gene :color, type: ColorGene  # Default count: 1
  #   ```
  #
  #   2. **Variable Count**: When you specify a range
  #
  #   ```ruby
  #   gene :skills, type: SkillGene, count: 1..5  # Can evolve between 1-5 skills
  #   ```
  #
  #   **Benefits**
  #
  #   - Declarative model definition
  #   - Automatic gene management
  #   - Self-evolving structure (with ranges)
  #   - Consistent instance initialization
  #
  # @see Evolvable::Gene
  # @see Evolvable::GeneCluster
  # @see Evolvable::Population
  #
  # @example
  #   # A simple example showing various gene definition options
  #   class Character
  #     include Evolvable
  #
  #     # Fixed count gene
  #     gene :name, type: NameGene, count: 1
  #
  #     # Variable count gene - can have between 1-20 skills
  #     gene :skills, type: SkillGene, count: 1..20
  #
  #     # Genes organized in a cluster
  #     gene :strength, type: AttributeGene, count: 1, cluster: :physical_stats
  #     gene :dexterity, type: AttributeGene, count: 1, cluster: :physical_stats
  #     gene :constitution, type: AttributeGene, count: 1, cluster: :physical_stats
  #
  #     # Access genes individually
  #     def describe
  #       puts "#{name} has #{skills.count} skills"
  #       puts "Strength: #{strength.value}"
  #     end
  #
  #     # Or access gene clusters
  #     def physical_power
  #       physical_stats.sum(&:value)
  #     end
  #   end
  #
  #   # Create a population and evolve it
  #   population = Character.new_population(size: 10)
  #   population.evolve(count: 5)
  #
  #   # The number of skills may have changed during evolution
  #   best_character = population.best_evolvable
  #   puts "Best character has #{best_character.skills.count} skills"
  #

  class GeneSpace
    class << self
      def build(config, evolvable_class = nil)
        if config.is_a?(GeneSpace)
          config.evolvable_class = evolvable_class if evolvable_class
          config
        else
          new(config: config, evolvable_class: evolvable_class)
        end
      end
    end

    def initialize(config: {}, evolvable_class: nil)
      @evolvable_class = evolvable_class
      @config = normalize_config(config)
    end

    attr_accessor :evolvable_class, :config

    def new_genome
      Genome.new(config: new_genome_config)
    end

    def merge_gene_space(val)
      val = val.config if val.is_a?(self.class)
      @config.merge normalize_config(val)
    end

    def merge_gene_space!(val)
      val = val.config if val.is_a?(self.class)
      @config.merge! normalize_config(val)
    end

    private

    def normalize_config(config)
      normalize_hash_config(config)
    end

    def normalize_hash_config(config)
      config.each do |gene_key, gene_config|
        next unless gene_config[:type]

        gene_class = lookup_gene_class(gene_config[:type])
        gene_class.key = gene_key
        gene_config[:class] = gene_class
      end
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
        Object.const_get(gene_config[:count]).new
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
end
