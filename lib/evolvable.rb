# frozen_string_literal: true

require 'forwardable'
require 'evolvable/version'
require 'evolvable/error/not_implemented'
require 'evolvable/gene'
require 'evolvable/gene_pool'
require 'evolvable/goal'
require 'evolvable/goal/equalize'
require 'evolvable/goal/maximize'
require 'evolvable/goal/minimize'
require 'evolvable/evaluator'
require 'evolvable/evolution'
require 'evolvable/selection'
require 'evolvable/crossover'
require 'evolvable/mutation'
require 'evolvable/population'

module Evolvable
  def self.included(base)
    def base.new_population(keyword_args = {})
      keyword_args[:evolvable_class] = self
      Population.new(**keyword_args)
    end

    def base.new_evolvable(genes, population, evolvable_index)
      evolvable = evolvable_initialize(genes: genes,
                                       population: population,
                                       evolvable_index: evolvable_index)
      evolvable.genes = genes
      evolvable.population = population
      evolvable.evolvable_index = evolvable_index
      evolvable
    end

    def base.new_gene_pool
      gene_configs = evolvable_genes || {}
      GenePool.new(gene_configs: gene_configs,
                   evolvable_genes_count: evolvable_genes_count)
    end

    def base.evolvable_initialize(genes:, population:, evolvable_index:)
      new
    end

    def base.evolvable_goal
      Goal::Maximize.new
    end

    def base.evolvable_genes; end

    def base.evolvable_genes_count; end

    def base.evolvable_evaluate!(population); end

    def base.evolvable_before_evolution(population); end

    def base.evolvable_after_evolution(population); end
  end

  attr_accessor :genes,
                :population,
                :evolvable_value,
                :evolvable_index

  def evolvable_value
    raise Errors::NotImplemented, __method__
  end

  def find_gene(key)
    @genes.detect { |g| g.evolvable_key == key }
  end

  def find_genes(key)
    @genes.select { |g| g.evolvable_key == key }
  end
end
