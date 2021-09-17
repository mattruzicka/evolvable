# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   TODO...
  #
  class Genome
    extend Forwardable

    def self.load(data)
      new(config: Serializer.load(data))
    end

    def initialize(config: {})
      @config = config
    end

    attr_reader :config

    #
    # Returns the first gene with the given key. In the Melody example above, the instrument gene has the key `:instrument` so we might write something like: `instrument_gene = melody.find_gene(instrument)`
    #
    # @param [<Type>] key <description>
    #
    # @return [<Type>] <description>
    #
    def find_gene(key)
      @config.dig(key, :genes, 0)
    end

    #
    # Returns an array of genes that have the given key. Gene keys are defined in the [EvolvableClass.search_space](#evolvableclasssearch_space) method. In the Melody example above, the key for the note genes would be `:notes`. The following would return an array of them: `note_genes = melody.find_genes(:notes)`
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

    def inspect
      self.class.name
    end

    def dump
      Serializer.dump @config
    end
  end
end
