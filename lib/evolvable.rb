# frozen_string_literal: true

require 'forwardable'
require 'evolvable/version'
require 'evolvable/error/undefined_method'
require 'evolvable/gene'
require 'evolvable/gene_space'
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

    def base.new_evolvable(population: nil, genes: [], evolvable_index: nil)
      evolvable = initialize_evolvable
      evolvable.population = population
      evolvable.genes = genes
      evolvable.evolvable_index = evolvable_index
      evolvable.initialize_evolvable
      evolvable
    end

    def base.initialize_evolvable
      new
    end

    def base.new_gene_space
      GeneSpace.new(evolvable_genes: evolvable_genes)
    end

    def base.evolvable_goal
      Goal::Maximize.new
    end

    def base.evolvable_genes
      {}
    end

    def base.evolvable_evaluate!(population); end

    def base.before_evolution(population); end

    def base.after_evolution(population); end
  end

  def initialize_evolvable; end

  attr_accessor :population,
                :genes,
                :evolvable_index

  def evolvable_value
    raise Errors::UndefinedMethod, "#{self.class.name}##{__method__}"
  end

  def find_gene(key)
    @genes.detect { |g| g.evolvable_key == key }
  end

  def find_genes(key)
    @genes.select { |g| g.evolvable_key == key }
  end
end
