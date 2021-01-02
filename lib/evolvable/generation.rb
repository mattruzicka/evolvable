# frozen_string_literal: true

module Evolvable
  class Generation
    def initialize(population)
      @instances = population.instances.dup
      @evolutions_count = population.evolutions_count
    end

    attr_reader :instances, :evolutions_count

    def best_instance
      instances.last
    end

    def best_value
      best_instance&.value
    end

    def inspect
      "Generation #{evolutions_count}"
    end
  end
end
