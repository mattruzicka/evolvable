# frozen_string_literal: true

module Evolvable
  class DataStore
    extend Forwardable

    def initialize(config = default_config)
      self.config = config
    end

    attr_reader :config

    def config=(config)
      @generation_save = config[:generation_save]
      @generation_step = config[:generation_step]
    end

    attr_accessor :generation_save,
                  :generation_step

    def default_config
      { generation_save: :all,
        generation_step: 1 }
    end

    def save_generation?(population)
      generation_save != :none && (population.evolutions_count % generation_step).zero?
    end

    def select_instances(population)
      case generation_save
      when :all
        population.instances.dup
      when :selection
        population.selection.call(population.instances.dup)
      when Numeric
        population.instances.last(generation_save)
      else
        generation_save&.call(population)
      end
    end

    def save_generation(_population)
      raise Errors::UndefinedMethod, "#{self.class.name}##{__method__}"
    end

    def load_generation(_generation_key)
      raise Errors::UndefinedMethod, "#{self.class.name}##{__method__}"
    end
  end
end