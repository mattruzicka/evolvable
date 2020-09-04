# frozen_string_literal: true

module Evolvable
  class Population
    extend Forwardable

    def initialize(id: nil,
                   evolvable_class:,
                   name: nil,
                   size: 40,
                   evolutions_count: 0,
                   gene_space: nil,
                   evolution: Evolution.new,
                   evaluator: Evaluator.new,
                   instances: [])
      @id = id
      @evolvable_class = evolvable_class
      @name = name
      @size = size
      @evolutions_count = evolutions_count
      @gene_space = gene_space || evolvable_class.new_gene_space
      @evolution = evolution
      @evaluator = evaluator || Evaluator.new
      initialize_instances(instances)
    end

    attr_accessor :id,
                  :evolvable_class,
                  :name,
                  :size,
                  :evolutions_count,
                  :gene_space,
                  :evolution,
                  :evaluator,
                  :instances

    def_delegators :evolvable_class,
                   :evolvable_evaluate!,
                   :before_evolution,
                   :after_evolution

    def_delegators :evolution,
                   :selection,
                   :selection=,
                   :crossover,
                   :crossover=,
                   :mutation,
                   :mutation=

    def_delegators :evaluator,
                   :goal,
                   :goal=

    def evolve(count: Float::INFINITY)
      (1..count).each do
        evaluator.call(self)
        before_evolution(self)
        break if met_goal?

        evolution.call(self)
        self.evolutions_count += 1
        after_evolution(self)
      end
    end

    def best_instance
      evaluator.best_instance(self)
    end

    def met_goal?
      evaluator.met_goal?(self)
    end

    def new_evolvable(genes: [], evolvable_index: nil)
      evolvable_class.new_evolvable(population: self,
                                    genes: genes,
                                    evolvable_index: evolvable_index)
    end

    private

    def initialize_instances(instances)
      @instances = instances || []
      (@size - instances.count).times do |n|
        genes = gene_space.initialize_genes
        @instances << new_evolvable(genes: genes, evolvable_index: n)
      end
    end
  end
end
