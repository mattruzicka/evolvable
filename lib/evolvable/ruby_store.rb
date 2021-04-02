module Evolvable
  class RubyStore < DataStore
    def initialize
      @generations = {}
    end

    attr_accessor :generations

    def save_generation(population)
      generations[population.generation_key] = select_instances(population)
    end

    def load_generation(generation_key)
      generations[generation_key]
    end
  end
end
