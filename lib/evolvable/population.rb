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
                   gene_space: nil, # Deprecated
                   search_space: nil,
                   evolution: Evolution.new,
                   evaluation: Evaluation.new,
                   parent_evolvables: [],
                   evolvables: [])
      @id = id
      @evolvable_type = evolvable_type || evolvable_class
      @name = name
      @size = size
      @evolutions_count = evolutions_count
      @search_space = initialize_search_space(search_space || gene_space)
      @evolution = evolution
      @evaluation = evaluation || Evaluation.new
      @parent_evolvables = parent_evolvables
      @evolvables = new_evolvables(count: @size - evolvables.count, evolvables: evolvables)
    end

    attr_accessor :id,
                  :evolvable_type,
                  :name,
                  :size,
                  :evolutions_count,
                  :search_space,
                  :evolution,
                  :evaluation,
                  :parent_evolvables,
                  :evolvables

    def_delegators :evolvable_class,
                   :before_evaluation,
                   :before_evolution,
                   :after_evolution

    def_delegators :evolution,
                   :selection,
                   :selection=,
                   :combination,
                   :combination=,
                   :mutation,
                   :mutation=

    def_delegator :selection, :size, :selection_size
    def_delegator :selection, :size=, :selection_size=

    def_delegator :mutation, :rate, :mutation_rate
    def_delegator :mutation, :rate=, :mutation_rate=
    def_delegator :mutation, :probability, :mutation_probability
    def_delegator :mutation, :probability=, :mutation_probability=

    def_delegators :evaluation,
                   :goal,
                   :goal=

    def evolve(count: Float::INFINITY, goal_value: nil)
      goal.value = goal_value if goal_value
      1.upto(count) do
        before_evaluation(self)
        evaluation.call(self)
        before_evolution(self)
        break if met_goal?

        evolution.call(self)
        self.evolutions_count += 1
        after_evolution(self)
      end
    end

    def best_evolvable
      evaluation.best_evolvable(self)
    end

    def met_goal?
      evaluation.met_goal?(self)
    end

    def new_evolvable(genome: nil)
      return generate_evolvables(1).first unless genome || parent_evolvables.empty?

      evolvable = evolvable_class.new_evolvable(population: self,
                                                genome: genome || search_space.new_genome,
                                                generation_index: @evolvables.count)
      @evolvables << evolvable
      evolvable
    end

    def new_evolvables(count:, evolvables: nil)
      evolvables ||= @evolvables || []
      @evolvables = evolvables

      if parent_evolvables.empty?
        Array.new(count) { new_evolvable(genome: search_space.new_genome) }
      else
        @evolvables = generate_evolvables(count)
      end
    end

    def reset_evolvables
      self.evolvables = []
      new_evolvables(count: size)
    end

    def new_parent_genome_cycle
      parent_evolvables.map(&:genome).shuffle!.combination(2).cycle
    end

    def evolvable_class
      @evolvable_class ||= evolvable_type.is_a?(Class) ? evolvable_type : Object.const_get(evolvable_type)
    end

    def dump(only: nil, except: nil)
      Serializer.dump(dump_attrs(only: only, except: except))
    end

    DUMP_METHODS = [:evolvable_type,
                    :id,
                    :name,
                    :size,
                    :evolutions_count,
                    :search_space,
                    :evolution,
                    :evaluation].freeze

    def dump_attrs(only: nil, except: nil)
      attrs = {}
      dump_methods = only || DUMP_METHODS
      dump_methods -= except if except
      dump_methods.each { |m| attrs[m] = send(m) }
      attrs
    end

    private

    def initialize_search_space(search_space)
      return SearchSpace.build(search_space, evolvable_class) if search_space

      evolvable_class.new_search_space
    end

    def generate_evolvables(count)
      evolvables = combination.new_evolvables(self, count)
      mutation.mutate_evolvables(evolvables)
      evolvables
    end
  end
end
