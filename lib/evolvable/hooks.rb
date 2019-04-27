module Evolvable
  module Hooks
    def evolvable_before_evaluation(population); end

    def evolvable_before_selection(population); end

    def evolvable_before_crossover(population); end

    def evolvable_before_mutation(population); end

    def evolvable_after_evolution(population); end
  end
end
