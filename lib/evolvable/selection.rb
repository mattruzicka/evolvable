# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Selection determines which evolvables will serve as parents for the next
  #   generation. You can control the selection process in several ways:
  #
  #   Set the selection size during population initialization:
  #
  #   ```ruby
  #   population = MyEvolvable.new_population(
  #     selection: { size: 3 }
  #   )
  #   ```
  #
  #   Adjust the selection size after initialization:
  #
  #   ```ruby
  #   population.selection_size = 4
  #   ```
  #
  #   Manually assign the selected evolvables:
  #
  #   ```ruby
  #   population.selected_evolvables = [evolvable1, evolvable2]
  #   ```
  #
  #   Or evolve a custom selection directly:
  #
  #   ```ruby
  #   population.evolve_selected([evolvable1, evolvable2])
  #   ```
  #
  #   This flexibility lets you implement custom selection strategies,
  #   overriding or augmenting the built-in behavior.
  #
  class Selection
    extend Forwardable

    #
    # Initializes a new selection object.
    #
    # @param size [Integer] The number of instances to select from each generation
    #   to perform crossover and generate or "breed" the next generation.
    #   The default is 2.
    #
    def initialize(size: 2)
      @size = size
    end

    #
    # The number of evolvables to select as parents for the next generation.
    # @return [Integer] The selection size
    #
    attr_accessor :size

    #
    # Performs selection on the population.
    # Takes the evaluated and sorted evolvables and selects a subset to
    # become parents for the next generation.
    #
    # @param population [Evolvable::Population] The population to perform selection on
    # @return [Evolvable::Population] The population with selected parent evolvables
    #
    def call(population)
      population.parent_evolvables = population.selected_evolvables.empty? ? select_evolvables(population.evolvables) : population.selected_evolvables
      population.selected_evolvables = []
      population.evolvables = []
      population
    end

    #
    # Selects the best evolvables from the given collection.
    # By default, selects the last N evolvables, where N is the selection size.
    # This assumes evolvables are already sorted in the evaluation step, with the best at the end.
    #
    # Override this method in a subclass to implement different selection strategies
    # such as tournament selection or roulette wheel selection.
    #
    # @example
    #   # A custom selection strategy using tournament selection
    #   class TournamentSelection < Evolvable::Selection
    #     def select_evolvables(evolvables)
    #       Array.new(size) do
    #         # Randomly select 3 individuals and pick the best one
    #         evolvables.sample(3).max_by(&:fitness)
    #       end
    #     end
    #   end
    #
    # @param evolvables [Array<Evolvable>] The evolvables to select from
    # @return [Array<Evolvable>] The selected evolvables to use as parents
    #
    def select_evolvables(evolvables)
      evolvables.last(@size)
    end
  end
end
