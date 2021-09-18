# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   After a population's instances are evaluated, they undergo evolution.
  #   The default evolution object is composed of selection,
  #   crossover, and mutation objects and applies them as operations to
  #   a population's evolvables in that order.
  #
  class Evolution
    extend Forwardable

    #
    #  Initializes a new evolution object.
    #
    # Keyword arguments:
    #
    # #### selection
    # The default is `Selection.new`
    # #### crossover - deprecated
    # The default is `GeneCrossover.new`
    # #### mutation
    # The default is `Mutation.new`
    #
    def initialize(selection: Selection.new,
                   combination: GeneCombination.new,
                   crossover: nil, # deprecated
                   mutation: Mutation.new)
      @selection = selection
      @combination = crossover || combination
      @mutation = mutation
    end

    attr_accessor :selection,
                  :combination,
                  :mutation

    def call(population)
      selection.call(population)
      combination.call(population)
      mutation.call(population)
      population
    end
  end
end
