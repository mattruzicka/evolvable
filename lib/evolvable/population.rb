# frozen_string_literal: true

module Evolvable
  class Population
    extend Forwardable

    def initialize(id: nil,
                   evolvable_class:,
                   name: nil,
                   size: 20,
                   evolutions_count: 0,
                   gene_pool: nil,
                   evolution: Evolution.new,
                   evaluator: Evaluator.new,
                   instances: [])
      @evolvable_class = evolvable_class
      @name = name
      @size = size
      @evolutions_count = evolutions_count
      @gene_pool = gene_pool || evolvable_class.new_gene_pool
      @evolution = evolution
      @evaluator = evaluator || Evaluator.new
      initialize_instances!(instances)
    end

    attr_accessor :id,
                  :evolvable_class,
                  :name,
                  :size,
                  :evolutions_count,
                  :gene_pool,
                  :evolution,
                  :evaluator,
                  :instances

    def_delegators :evolvable_class,
                   :new_evolvable,
                   :evolvable_evaluate!,
                   :evolvable_before_evolution,
                   :evolvable_after_evolution

    def_delegators :evolution,
                   :selection,
                   :crossover,
                   :mutation

    def_delegators :evaluator,
                   :goal,
                   :goal=

    def evolve!(count: Float::INFINITY)
      (1..count).each do
        @evaluator.call!(self)
        @evaluator.sort!(self)
        break if @evaluator.met_goal?(self)

        evolvable_before_evolution(self)
        evolution.evolve!(self)
        @evolutions_count += 1
        evolvable_after_evolution(self)
      end
    end

    def best_instance
      @evaluator.best_instance(self)
    end

    private

    def initialize_instances!(instances)
      @instances = instances || []
      (@size - instances.count).times do |n|
        genes = gene_pool.initialize_instance_genes
        @instances << new_evolvable(genes, self, n)
      end
    end
  end
end
