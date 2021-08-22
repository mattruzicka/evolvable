# frozen_string_literal: true

require 'forwardable'
require 'evolvable/version'
require 'evolvable/error/undefined_method'
require 'evolvable/gene'
require 'evolvable/search_space'
require 'evolvable/genome'
require 'evolvable/goal'
require 'evolvable/equalize_goal'
require 'evolvable/maximize_goal'
require 'evolvable/minimize_goal'
require 'evolvable/evaluation'
require 'evolvable/evolution'
require 'evolvable/selection'
require 'evolvable/gene_combination'
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
    base.extend(ClassMethods)
  end

  module ClassMethods
    def new_population(keyword_args = {})
      keyword_args[:evolvable_type] = self
      Population.new(**keyword_args)
    end

    def new_evolvable(population: nil,
                      genome: Genome.new,
                      generation_index: nil)
      evolvable = initialize_evolvable
      evolvable.population = population
      evolvable.genome = genome
      evolvable.generation_index = generation_index
      evolvable.initialize_evolvable
      evolvable
    end

    def initialize_evolvable
      new
    end

    def new_search_space
      space_config = search_space.empty? ? gene_space : search_space
      search_space = SearchSpace.build(space_config, self)
      search_spaces.each { |space| search_space.merge_search_space!(space) }
      search_space
    end

    def search_space
      {}
    end

    def search_spaces
      []
    end

    # Deprecated. Will be removed in 2.0
    # use Evolvable::EqualizeGoal instead
    def gene_space
      {}
    end

    def before_evaluation(population); end

    def before_evolution(population); end

    def after_evolution(population); end
  end

  def initialize_evolvable; end

  attr_accessor :id,
                :population,
                :genome,
                :generation_index,
                :value

  # Deprecated. The population_index method will be
  # removed in version 2.0
  alias population_index generation_index

  def_delegators :genome,
                 :find_gene,
                 :find_genes,
                 :find_genes_count,
                 :genes
end
