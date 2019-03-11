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
                   objects: [])
      @evolvable_class = evolvable_class
      @size = size
      @selection_count = selection_count
      @crossover = crossover
      @mutation = mutation
      @generation_count = generation_count
      @log_progress = log_progress
      assign_objects(objects)
    end

    attr_accessor :evolvable_class,
                  :size,
                  :selection_count,
                  :crossover,
                  :mutation,
                  :generation_count,
                  :log_progress,
                  :objects

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
        evaluate_objects!
        log_evolvable_progress if log_progress
        break if fitness_goal_met?

        select_objects!
        evolvable_after_select(self)
        crossover_objects!
        mutate_objects!
        evolvable_after_evolution(self)
      end
    end

    def strongest_object
      objects.max_by(&:fitness)
    end

    def evaluate_objects!
      evolvable_evaluate!(@objects)
      if @fitness_goal
        @objects.sort_by! { |i| -(i.fitness - @fitness_goal).abs }
      else
        @objects.sort_by!(&:fitness)
      end
    end

    def log_evolvable_progress
      @objects.last.evolvable_progress
    end

    def fitness_goal_met?
      @fitness_goal && @objects.last.fitness >= @fitness_goal
    end

    def select_objects!
      @objects.slice!(0..-1 - @selection_count)
    end

    def crossover_objects!
      parent_genes = @objects.map(&:genes)
      offspring_genes = @crossover.call(parent_genes, @size)
      @objects = offspring_genes.map.with_index do |genes, i|
        evolvable_initialize(genes, self, i)
      end
    end

    def mutate_objects!
      @mutation.call!(@objects)
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

    def assign_objects(objects)
      @objects = objects || []
      (@size - objects.count).times do |n|
        genes = evolvable_random_genes
        @objects << evolvable_initialize(genes, self, n)
      end
    end
  end
end
