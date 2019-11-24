module Evolvable
  class Selection
    extend Forwardable

    def initialize(count: 2)
      @count = count
    end

    attr_accessor :count

    def call!(population)
      population.objects.slice!(0..-1 - @count)
      population
    end
  end
end
