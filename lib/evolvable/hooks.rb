module Evolvable
  module Hooks
    def evolvable_before_evolution(population); end

    def evolvable_after_select(population); end

    def evolvable_after_evolution(population); end
  end
end