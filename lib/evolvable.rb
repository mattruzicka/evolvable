# frozen_string_literal: true

require 'forwardable'
require 'logger'

require 'evolvable/version'
require 'evolvable/population'
require 'evolvable/crossover'
require 'evolvable/mutation'
require 'evolvable/helper_methods'
require 'evolvable/evolution_callbacks'
require 'evolvable/errors/not_implemented'

module Evolvable
  extend HelperMethods

  def self.included(base)
    base.extend EvolutionCallbacks

    def base.evolvable_gene_pool
      raise Errors::NotImplemented, __method__
    end

    def base.evolvable_genes_count
      @evolvable_genes_count ||= evolvable_gene_pool_size
    end

    def base.evolvable_evaluate!(_individuals); end

    def base.evolvable_initialize(genes, generation_count, individual_index)
      new(name: "#{self} #{generation_count}.#{individual_index}",
          genes: genes)
    end

    def base.evolvable_population_attrs
      {}
    end

    def base.evolvable_population(args = {})
      args = evolvable_population_attrs.merge!(args)
      args[:evolvable_class] = self
      Population.new(args)
    end

    def base.evolvable_gene_pool_cache
      @evolvable_gene_pool_cache ||= evolvable_gene_pool
    end

    def base.evolvable_gene_pool_size
      @evolvable_gene_pool_size ||= evolvable_gene_pool_cache.size
    end

    def base.evolvable_random_genes(count = nil)
      gene_pool = evolvable_gene_pool_cache
      count ||= evolvable_genes_count
      gene_pool = gene_pool.sample(count) if count < gene_pool.size
      genes = {}
      gene_pool.each { |name, potentials| genes[name] = potentials.sample }
      genes
    end
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def initialize(name: nil, genes: [])
    @name = name
    @genes = genes
  end

  attr_reader :name,
              :genes

  def fitness
    raise Errors::NotImplemented, __method__
  end

  def evolvable_progress
    "Fitness: #{fitness}"
  end
end
