# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   **Evolution** moves a population from one generation to the next.
  #   It runs in three steps: selection, combination, and mutation.
  #   You can swap out any step with your own strategy.
  #
  #   Default pipeline:
  #   1. **Selection** – keep the most fit evolvables
  #   2. **Combination** – create offspring by recombining genes
  #   3. **Mutation** – add random variation to preserve diversity
  #
  class Evolution
    extend Forwardable

    #
    # Initializes a new evolution object.
    #
    # @param selection [Evolvable::Selection, Hash] The selection strategy
    # @param combination [Evolvable::Combination, Hash] The combination strategy
    # @param mutation [Evolvable::Mutation, Hash] The mutation strategy
    #
    def initialize(selection: Selection.new,
                   combination: GeneCombination.new,
                   mutation: Mutation.new)
      @selection = selection
      @combination = combination
      @mutation = mutation
    end

    attr_reader :selection,
                :combination,
                :mutation

    #
    # Sets the selection strategy.
    #
    # @param val [Evolvable::Selection, Hash] The new selection strategy or configuration hash
    # @return [Evolvable::Selection] The updated selection object
    #
    def selection=(val)
      @selection = Evolvable.new_object(@selection, val, Selection)
    end

    #
    # Sets the combination strategy.
    #
    # @param val [Evolvable::Combination, Hash] The new combination strategy or configuration hash
    # @return [Evolvable::Combination] The updated combination object
    #
    def combination=(val)
      @combination = Evolvable.new_object(@combination, val, GeneCombination)
    end

    #
    # Sets the mutation strategy.
    #
    # @param val [Evolvable::Mutation, Hash] The new mutation strategy or configuration hash
    # @return [Evolvable::Mutation] The updated mutation object
    #
    def mutation=(val)
      @mutation = Evolvable.new_object(@mutation, val, Mutation)
    end

    #
    # Executes the evolution process on the population.
    # Applies selection, combination, and mutation in sequence.
    #
    # @param population [Evolvable::Population] The population to evolve
    # @return [Evolvable::Population] The evolved population
    #
    def call(population)
      selection.call(population)
      combination.call(population)
      mutation.call(population)
      population
    end
  end
end
