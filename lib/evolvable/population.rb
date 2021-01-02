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
                   evaluation: Evaluation.new,
                   data_store: DataStore.new,
                   instances: [])
      @id = id
      @evolvable_class = evolvable_class
      @name = name
      @size = size
      @evolutions_count = evolutions_count
      @gene_space = initialize_gene_space(gene_space)
      @evolution = evolution
      @evaluation = evaluation || Evaluation.new
      @data_store = data_store
      initialize_instances(instances)
    end

    attr_accessor :id,
                  :evolvable_class,
                  :name,
                  :size,
                  :evolutions_count,
                  :gene_space,
                  :evolution,
                  :evaluation,
                  :instances,
                  :data_store

    def_delegators :evolvable_class,
                   :before_evaluation,
                   :before_evolution,
                   :after_evolution

    def_delegators :evolution,
                   :selection,
                   :selection=,
                   :crossover,
                   :crossover=,
                   :mutation,
                   :mutation=

    def_delegators :evaluation,
                   :goal,
                   :goal=

    def evolve(count: Float::INFINITY, goal_value: nil)
      goal.value = goal_value if goal_value
      (1..count).each do
        before_evaluation(self)
        evaluation.call(self)
        save_generation if save_generation?
        before_evolution(self)
        break if met_goal?

        evolution.call(self)
        self.evolutions_count += 1
        after_evolution(self)
      end
    end

    def best_instance
      evaluation.best_instance(self)
    end

    def best_value
      evaluation.best_value(self)
    end

    def met_goal?
      evaluation.met_goal?(self)
    end

    def new_instance(genes: [], population_index: nil)
      evolvable_class.new_instance(genes: genes,
                                   evolutions_count: evolutions_count,
                                   population_index: population_index)
    end

    def_delegators :data_store, :generations

    def save_generation
      data_store.save_generation(self)
    end

    def save_generation?
      data_store&.save_generation?(self)
    end

    private

    def initialize_gene_space(gene_space)
      return GeneSpace.build(gene_space) if gene_space

      evolvable_class.new_gene_space
    end

    def initialize_instances(instances)
      @instances = instances || []
      (@size - instances.count).times do |n|
        genes = gene_space.new_genes
        @instances << new_instance(genes: genes, population_index: n)
      end
    end
  end
end
