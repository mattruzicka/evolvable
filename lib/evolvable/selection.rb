# frozen_string_literal: true

module Evolvable
  class Selection
    extend Forwardable

    def initialize(count: 2)
      @count = count
    end

    attr_accessor :count

    def call!(population)
      population.instances.slice!(0..-1 - @count)
      population
    end
  end
end
