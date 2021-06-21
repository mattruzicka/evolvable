# frozen_string_literal: true

module Evolvable
  class Selection
    extend Forwardable

    def initialize(size: 2)
      @size = size
    end

    attr_accessor :size

    def call(population)
      population.parent_instances = select_instances(population.instances)
      population.instances = []
      population
    end

    def select_instances(instances)
      instances.last(@size)
    end
  end
end
