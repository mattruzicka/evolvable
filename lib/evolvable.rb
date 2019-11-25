# frozen_string_literal: true

require 'forwardable'
require 'evolvable/version'
require 'evolvable/error/not_implemented'
require 'evolvable/gene'
require 'evolvable/gene_pool'
require 'evolvable/goal.rb'
require 'evolvable/goal/equalize'
require 'evolvable/goal/maximize'
require 'evolvable/goal/minimize'
require 'evolvable/evolution'
require 'evolvable/evaluator'
require 'evolvable/selection'
require 'evolvable/crossover'
require 'evolvable/mutation'
require 'evolvable/population'

module Evolvable
  def self.included(base)
    def base.new_population(args = {})
      args[:evolvable_class] = self
      Population.new(args)
    end

    def base.new_evolvable(genes, population, evolvable_index)
      evolvable = new
      evolvable.genes = genes
      evolvable.population = population
      evolvable.evolvable_index = evolvable_index
      evolvable
    end

    def base.new_gene_pool
      define_gene_getters
      GenePool.new(gene_configs: evolvable_genes || {},
                   evolvable_genes_count: evolvable_genes_count)
    end

    def base.evolvable_goal
      Goal::Maximize.new
    end

    def base.evolvable_genes; end

    def base.evolvable_genes_count; end

    def base.evolvable_evaluate!(population); end

    def base.evolvable_before_evolution(population); end

    def base.evolvable_after_evolution(population); end

    private

    def base.define_gene_getters
      evolvable_genes.each_key do |gene_key|
        define_method(gene_key) { genes_by_key(gene_key) }
      end
    end
  end

  attr_accessor :genes,
                :population,
                :evolvable_value,
                :evolvable_index

  def evolvable_value
    raise Errors::NotImplemented, __method__
  end

  private

  def genes_by_key(key)
    @genes_by_key ||= @genes.group_by(&:evolvable_key)
    @genes_by_key[key] || []
  end
end
