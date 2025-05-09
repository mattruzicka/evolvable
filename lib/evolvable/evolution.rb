# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   After a population's instances are evaluated, they undergo evolution.
  #   The default evolution object is composed of selection,
  #   combination, and mutation objects and applies them as operations to
  #   a population's evolvables in that order.
  #
  #   Each evolutionary operation can be customized individually, allowing you to
  #   fine-tune the evolutionary process to fit your specific problem domain.
  #
  # @example
  #   # Create a population with custom evolution settings
  #   population = MyEvolvable.new_population(
  #     selection: { size: 3 },
  #     mutation: { probability: 0.1 }
  #   )
  #
  #   population.evolve
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

    #
    # The selection strategy used for choosing parent evolvables.
    # @return [Evolvable::Selection] The current selection object
    #
    attr_reader :selection,
                #
                # The combination strategy used for creating new evolvables.
                # @return [Evolvable::Combination] The current combination object
                #
                :combination,
                #
                # The mutation strategy used for introducing variation.
                # @return [Evolvable::Mutation] The current mutation object
                #
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
