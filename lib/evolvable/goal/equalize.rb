module Evolvable::Goal
  class Equalize
    include Evolvable::Goal

    def value
      @value ||= 0
    end

    def evaluate(object)
      -(object.value - value).abs
    end

    def met?(object)
      object.value == value
    end
  end
end
