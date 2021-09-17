# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   The selection object assumes that a population's evolvables have already
  #   been sorted by the evaluation object. It selects "parent" evolvables to
  #   undergo combination and thereby produce the next generation of evolvables.
  #
  #   Only two evolvables are selected as parents for each generation by default.
  #   This number can be configured.
  #
  class Selection
    extend Forwardable

    #
    # Initializes a new selection object.
    #
    # Keyword arguments:
    #
    # #### size
    # The number of instances to select from each generation from which to
    # perform crossover and generate or "breed" the next generation. The
    # number of parents The default is 2.
    #
    def initialize(size: 2)
      @size = size
    end

    attr_accessor :size

    def call(population)
      population.parent_evolvables = select_evolvables(population.evolvables)
      population.evolvables = []
      population
    end

    def select_evolvables(evolvables)
      evolvables.last(@size)
    end
  end
end
