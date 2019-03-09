# frozen_string_literal: true

module Evolvable
  class Population
    extend Forwardable

    def initialize(evolvable_class:,
                   size: 20,
                   selection_count: 2,
                   crossover: Crossover.new,
                   mutation: Mutation.new,
                   generation_count: 0,
                   log_progress: false,
                   individuals: [])
      @evolvable_class = evolvable_class
      @size = size
      @selection_count = selection_count
      @crossover = crossover
      @mutation = mutation
      @generation_count = generation_count
      @log_progress = log_progress
      assign_individuals(individuals)
    end

    attr_reader :evolvable_class,
                :size,
                :selection_count,
                :crossover,
                :mutation,
                :generation_count,
                :individuals

    def_delegators :@evolvable_class,
                   :evolvable_evaluate!,
                   :evolvable_initialize,
                   :evolvable_random_genes,
                   :evolvable_before_evolution,
                   :evolvable_after_select,
                   :evolvable_after_evolution

    def evolve!(generations_count: 1, fitness_goal: nil)
      @fitness_goal = fitness_goal
      generations_count.times do
        @generation_count += 1
        evolvable_before_evolution(self)
        evaluate_individuals!
        log_progress if @log_progress
        break if fitness_goal_met?

        select_individuals!
        evolvable_after_select(self)
        reproduce_individuals!
        mutate_individuals!
        evolvable_after_evolution(self)
      end
    end

    def evaluate_individuals!
      evolvable_evaluate!(@individuals)
      if @fitness_goal
        @individuals.sort_by! { |i| -(i.fitness - @fitness_goal).abs }
      else
        @individuals.sort_by!(&:fitness)
      end
    end

    def log_progress
      @individuals.last.evolvable_progress
    end

    def fitness_goal_met?
      @fitness_goal && @individuals.last.fitness >= @fitness_goal
    end

    def select_individuals!
      @individuals.slice!(0..-1 - @selection_count)
    end

    def reproduce_individuals!
      parent_genes = @individuals.map(&:genes)
      offspring_genes = @crossover.call(parent_genes, @size)
      @individuals = offspring_genes.map.with_index do |genes, i|
        evolvable_initialize(genes, self, i)
      end
    end

    def mutate_individuals!
      @mutation.call!(@individuals)
    end

    def inspect
      "#<#{self.class.name} #{as_json} >"
    end

    def as_json
      { evolvable_class: @evolvable_class.name,
        size: @size,
        selection_count: @selection_count,
        crossover: @crossover.as_json,
        mutation: @mutation.as_json,
        generation_count: @generation_count }
    end

    private

    def assign_individuals(individuals)
      @individuals = individuals || []
      (@size - individuals.count).times do |n|
        genes = evolvable_random_genes
        @individuals << evolvable_initialize(genes, self, n)
      end
    end
  end
end
