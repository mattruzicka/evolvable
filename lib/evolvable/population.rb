# frozen_string_literal: true

module Evolvable
  class Population
    extend Forwardable

    def initialize(evolvable_class:,
                   population_size:,
                   selection_count:,
                   crossover: Crossover.new,
                   mutation: Mutation.new,
                   generation_count: 0,
                   individuals: [])
      @evolvable_class = evolvable_class
      @population_size = population_size
      @selection_count = selection_count
      @crossover = crossover
      @mutation = mutation
      @mutation_rate = mutation_rate
      @generation_count = generation_count
      assign_individuals(individuals)
    end

    def_delegators :@evolvable_class,
                   :evolvable_evaluate,
                   :evolvable_initialize,
                   :evolvable_genes_count,
                   :evolvable_gene_pool

    def evolve!(generations_count)
      generations_count.times do
        evaluate_individuals!
        select_individuals!
        reproduce_individuals!
        mutate_individuals!
        @generation_count += 1
      end
    end

    def evaluate_individuals!
      evolvable_evaluate!(@individuals)
    end

    def select_individuals!
      @individuals.sort_by!(&:fitness).slice!(0..-1 - @selection_count)
    end

    def reproduce_individuals!
      parent_genes = @individuals.map(&:genes)
      offspring_genes = @crossover.call(parent_genes, @population_size)
      offspring_genes.each_with_index do |genes, i|
        @individuals << evolvable_initialize(genes, @generation_count, i)
      end
    end

    def mutate_individuals!
      @mutation.call!(@individuals)
    end

    private

    def assign_individuals(individuals)
      @individuals = individuals || []
      (@population_size - individuals.count).times do |n|
        genes = Evolvable.random_genes(@evolvable_class)
        @individuals << evolvable_initialize(genes, @generation_count, n)
      end
    end
  end
end
