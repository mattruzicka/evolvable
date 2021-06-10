# frozen_string_literal: true

module Evolvable
  class Population
    extend Forwardable

    def self.load(data)
      dump_attrs = Serializer.load(data)
      new(**dump_attrs)
    end

    def initialize(evolvable_type: nil,
                   evolvable_class: nil, # Deprecated
                   id: nil,
                   name: nil,
                   size: 40,
                   evolutions_count: 0,
                   gene_space: nil,
                   evolution: Evolution.new,
                   evaluation: Evaluation.new,
                   instances: [])
      @id = id
      @evolvable_type = evolvable_type || evolvable_class
      @name = name
      @size = size
      @evolutions_count = evolutions_count
      @gene_space = initialize_gene_space(gene_space)
      @evolution = evolution
      @evaluation = evaluation || Evaluation.new
      new_instances(instances)
    end

    attr_accessor :id,
                  :evolvable_type,
                  :name,
                  :size,
                  :evolutions_count,
                  :gene_space,
                  :evolution,
                  :evaluation,
                  :instances

    def_delegators :evolvable_type,
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

    def met_goal?
      evaluation.met_goal?(self)
    end

    def new_instance(genome: nil)
      genome ||= gene_space.new_genome
      instance = evolvable_class.new_instance(population: self,
                                              genome: genome,
                                              generation_index: @instances.count)
      @instances << instance
      instance
    end

    def new_instances(instances = nil)
      instances ||= @instances || []
      @instances = instances
      Array.new(@size - @instances.count) { new_instance }
    end

    def evolvable_class
      @evolvable_class ||= evolvable_type.is_a?(Class) ? evolvable_type : Kernel.const_get(evolvable_type)
    end

    def dump
      Serializer.dump(dump_attrs)
    end

    def dump_attrs
      { evolvable_type: evolvable_type,
        id: id,
        name: name,
        size: size,
        evolutions_count: evolutions_count,
        gene_space: gene_space,
        evolution: evolution,
        evaluation: evaluation }
    end

    private

    def initialize_gene_space(gene_space)
      return GeneSpace.build(gene_space) if gene_space

      evolvable_class.new_gene_space
    end
  end
end
