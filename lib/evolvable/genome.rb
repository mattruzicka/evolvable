# frozen_string_literal: true

module Evolvable
  #
  # The Genome class represents the fully instantiated genetic blueprint of an evolvable instance.
  # It stores all gene data in a structured, accessible form and provides methods to inspect,
  # manipulate, and serialize that genetic information.
  #
  # A genome consists of:
  # - A hash of gene configurations organized by key
  # - Count genes that determine how many instances of each gene type are present
  # - The actual gene instances used by the evolvable
  #
  # The genome acts as the bridge between the gene space (definition) and the
  # evolvable instance (implementation), enabling flexible gene access and
  # supporting dynamic mutation or crossover behavior.
  #
  # @see Evolvable::GeneSpace
  # @see Evolvable::GeneCombination
  # @see Evolvable::Gene
  #
  class Genome
    extend Forwardable

    def self.load(data, serializer: Serializer)
      new(config: serializer.load(data))
    end

    def initialize(config: {})
      @config = config
    end

    attr_reader :config

    alias to_h config

    #
    # Returns the first gene with the given key. In the Melody example above, the instrument
    # gene has the key `:instrument` so we might write something like:
    #
    # ```ruby
    # instrument_gene = melody.find_gene(instrument)
    # ```
    #
    # @param [<Type>] key <description>
    #
    # @return [<Type>] <description>
    #
    def find_gene(key)
      @config.dig(key, :genes, 0)
    end

    #
    # Returns an array of genes that have the given key. Gene keys are defined using the
    # [EvolvableClass.gene](https://mattruzicka.github.io/evolvable/Evolvable/ClassMethods#gene-instance_method)
    # macro method. In the Melody example above, the key for the note genes would be `:notes`.
    # The following would return an array of them: `note_genes = melody.find_genes(:notes)`
    #
    # @param [<Type>] *keys <description>
    #
    # @return [<Type>] <description>
    #
    def find_genes(*keys)
      keys.flatten!
      return @config.dig(keys.first, :genes) if keys.count <= 1

      @config.values_at(*keys).flat_map { _1&.fetch(:genes, []) || [] }
    end

    #
    # <Description>
    #
    # @param [<Type>] key <description>
    #
    # @return [<Type>] <description>
    #
    def find_genes_count(key)
      find_count_gene(key).count
    end

    #
    # <Description>
    #
    # @param [<Type>] key <description>
    #
    # @return [<Type>] <description>
    #
    def find_count_gene(key)
      @config.dig(key, :count_gene)
    end

    def_delegators :config, :each

    def gene_keys
      @config.keys
    end

    def genes
      @config.flat_map { |_gene_key, gene_config| gene_config[:genes] }
    end

    def merge!(other_genome)
      @config.merge!(other_genome.config)
    end

    def inspect
      self.class.name
    end

    def dump(serializer: Serializer)
      serializer.dump @config
    end
  end
end
