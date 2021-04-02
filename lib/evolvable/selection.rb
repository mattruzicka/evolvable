# frozen_string_literal: true

module Evolvable
  class Selection
    extend Forwardable

    def initialize(size: 2)
      @size = size
    end

    attr_accessor :size

    def call(instances)
      instances.slice!(0..-1 - @size)
      instances
    end
  end
end
