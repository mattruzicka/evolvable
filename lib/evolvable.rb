# frozen_string_literal: true

require 'forwardable'
require 'logger'

require 'evolvable/version'
require 'evolvable/population'
require 'evolvable/crossover'
require 'evolvable/mutation'
require 'evolvable/helper_methods'
require 'evolvable/hooks'
require 'evolvable/errors/not_implemented'

module Evolvable
  extend HelperMethods

  def self.included(base)
    base.extend Hooks

    def base.evolvable_gene_pool
      raise Errors::NotImplemented, __method__
    end

    def base.evolvable_genes_count
      evolvable_gene_pool_size
    end

    def base.evolvable_evaluate!(_objects); end

    def base.evolvable_population_attrs
      {}
    end

    def base.evolvable_population(args = {})
      clear_evolvable_gene_pool_caches
      args = evolvable_population_attrs.merge!(args)
      args[:evolvable_class] = self
      Population.new(args)
    end

    def base.evolvable_initialize(genes, population, _object_index)
      evolvable = new
      evolvable.genes = genes
      evolvable.population = population
      evolvable
    end

    def base.evolvable_gene_pool_cache
      @evolvable_gene_pool_cache ||= evolvable_gene_pool
    end

    def base.evolvable_gene_pool_size
      @evolvable_gene_pool_size ||= evolvable_gene_pool_cache.size
    end

    def base.clear_evolvable_gene_pool_caches
      @evolvable_gene_pool_cache = nil
      @evolvable_gene_pool_size = nil
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

  attr_accessor :genes,
                :population

  def fitness
    raise Errors::NotImplemented, __method__
  end

  def evolvable_progress(info = nil)
    info ||= "Generation: #{population.generation_count} | Fitness: #{fitness}"
    Evolvable.logger.info(info)
  end
end
