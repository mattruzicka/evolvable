# frozen_string_literal: true

require 'forwardable'
require 'evolvable/version'
require 'evolvable/error/undefined_method'
require 'evolvable/gene'
require 'evolvable/gene_space'
require 'evolvable/genome'
require 'evolvable/goal'
require 'evolvable/equalize_goal'
require 'evolvable/maximize_goal'
require 'evolvable/minimize_goal'
require 'evolvable/evaluation'
require 'evolvable/evolution'
require 'evolvable/selection'
require 'evolvable/gene_crossover'
require 'evolvable/point_crossover'
require 'evolvable/uniform_crossover'
require 'evolvable/mutation'
require 'evolvable/population'
require 'evolvable/count_gene'
require 'evolvable/rigid_count_gene'
require 'evolvable/serializer'

module Evolvable
  extend Forwardable

  def self.included(base)
    def base.new_population(keyword_args = {})
      keyword_args[:evolvable_type] = self
      Population.new(**keyword_args)
    end

    def base.new_instance(population: nil,
                          genome: Genome.new,
                          generation_index: nil)
      evolvable = initialize_instance
      evolvable.population = population
      evolvable.genome = genome
      evolvable.generation_index = generation_index
      evolvable.initialize_instance
      evolvable
    end

    def base.initialize_instance
      new
    end

    def base.new_gene_space
      GeneSpace.build(gene_space)
    end

    def base.gene_space
      {}
    end

    def base.before_evaluation(population); end

    def base.before_evolution(population); end

    def base.after_evolution(population); end
  end

  def initialize_instance; end

  attr_accessor :id,
                :population,
                :genome,
                :generation_index

  # Deprecated. The population_index method will be
  # removed in version 2.0
  alias population_index generation_index

  def value
    raise Errors::UndefinedMethod, "#{self.class.name}##{__method__}"
  end

  def_delegators :genome,
                 :find_gene,
                 :find_genes,
                 :find_gene_count,
                 :genes
end
