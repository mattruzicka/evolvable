module Evolvable
  module Hooks
    def evolvable_before_evaluation(population); end

    def evolvable_after_select(population); end

    def evolvable_after_evolution(population); end
  end
end
