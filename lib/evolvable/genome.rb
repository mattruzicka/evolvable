# frozen_string_literal: true

module Evolvable
  class Genome
    extend Forwardable

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

      @config.values_at(*keys).flat_map { _1.fetch(:genes, []) }
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

    def each_gene_key
      @config.each_key
    end

    def each_gene_config
      @config.each_value
    end

    def genes
      each_gene_config.flat_map { |gc| gc[:genes] }
    end

    def inspect
      self.class.name
    end
  end
end
