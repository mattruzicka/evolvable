# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   The gene space encapsulates the range of possible genes
  #   for a particular evolvable. You can think of it as the search space
  #   for genes or the boundaries of genetic variation. It is configured via the
  #   `.gene` macro-style method that you use to define genetic attributes on
  #   your evolvable class. These gene definitions are used by populations
  #   to initialize new evolvables.
  #
  #   Evolvable provides a clean, declarative approach to defining your genetic model
  #   structure. Here's how you might define genes for a music evolution program:
  #
  # @example
  #   class Melody
  #     include Evolvable
  #
  #     gene :notes, type: NoteGene, count: 4..16
  #     gene :instrument, type: InstrumentGene, count: 1
  #     gene :tempo, type: TempoGene, count: 1
  #
  #     # Define audio effects as a cluster of related genes
  #     gene :reverb, type: ReverbGene, count: 0..1, cluster: :effects
  #     gene :delay, type: DelayGene, count: 0..1, cluster: :effects
  #     gene :distortion, type: DistortionGene, count: 0..1, cluster: :effects
  #     gene :chorus_effect, type: ChorusEffectGene, count: 0..1, cluster: :effects
  #
  #     def play
  #       # Access genes directly or through their clusters
  #       instrument.play(notes, tempo, effects)
  #     end
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
