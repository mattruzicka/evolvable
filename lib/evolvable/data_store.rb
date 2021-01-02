# frozen_string_literal: true

module Evolvable
  class DataStore
    def initialize(config = default_config)
      self.config = config
      @generations = []
    end

    def config=(config)
      @save_generations = config[:save_generations]
      @save_generations_step = config[:save_generations_step]
    end

    def default_config
      { save_generations: false, save_generations_step: 1 }
    end

    attr_reader :config, :generations

    attr_accessor :save_generations, :save_generations_step

    def save_generation(population)
      @generations << Generation.new(population)
    end

    def save_generation?(population)
      @save_generations && (population.evolutions_count % @save_generations_step).zero?
    end
  end
end