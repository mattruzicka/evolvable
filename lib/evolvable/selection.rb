# frozen_string_literal: true

module Evolvable
  class Selection
    extend Forwardable

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
