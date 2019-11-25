# frozen_string_literal: true

module Evolvable
  class Evolution
    extend Forwardable

    def initialize(selection: Selection.new,
                   crossover: Crossover.new,
                   mutation: Mutation.new)
      @selection = selection
      @crossover = crossover
      @mutation = mutation
    end

    attr_accessor :selection,
                  :crossover,
                  :mutation

    def evolve!(population)
      @selection.call!(population)
      @crossover.call!(population)
      @mutation.call!(population)
    end
  end
end
