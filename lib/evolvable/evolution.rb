# frozen_string_literal: true

module Evolvable
  class Evolution
    extend Forwardable

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
