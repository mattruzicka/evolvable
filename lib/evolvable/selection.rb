# frozen_string_literal: true

module Evolvable
  class Selection
    extend Forwardable

    def initialize(size: 2)
      @size = size
    end

    attr_accessor :size

    def call(population)
      population.instances.slice!(0..-1 - @size)
      population
    end
  end
end
