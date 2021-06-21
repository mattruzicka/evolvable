# frozen_string_literal: true

module Evolvable
  class Genome
    extend Forwardable

    def self.load(data)
      new(config: Serializer.load(data))
    end

    def initialize(config: {})
      @config = config
    end

    attr_reader :config

    def find_gene(key)
      @config.dig(key, :genes, 0)
    end

    def find_genes(*keys)
      keys.flatten!
      return @config.dig(keys.first, :genes) if keys.count <= 1

      @config.values_at(*keys).flat_map { _1&.fetch(:genes, []) || [] }
    end

    def find_gene_count(key)
      find_count_gene(key).count
    end

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
