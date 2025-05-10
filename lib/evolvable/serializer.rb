# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Evolvable supports saving and restoring the state of both populations
  #   and individual evolvable instances through a built-in `Serializer`.
  #   By default, it uses Ruby's `Marshal` class for fast, portable binary serialization.
  #
  #   Serialization is useful for:
  #   - Saving progress during long-running evolution
  #   - Storing champion solutions for later reuse
  #   - Transferring evolved populations between systems
  #   - Creating checkpoints you can revert to
  #
  #   Both `Population` and individual evolvables expose `dump` and `load` methods
  #   that use the `Serializer` internally.
  #
  #   Save a population to a file:
  #
  #   ```ruby
  #   population = YourEvolvable.new_population
  #   population.evolve(count: 100)
  #   File.write("population.marshal", population.dump)
  #   ```
  #
  #   Restore and continue evolution:
  #
  #   ```ruby
  #   data = File.read("population.marshal")
  #   restored = Evolvable::Population.load(data)
  #   restored.evolve(count: 100)
  #   ```
  #
  #   Save an individual evolvable's genome:
  #
  #   ```ruby
  #   best = restored.best_evolvable
  #   File.write("champion.marshal", best.dump_genome)
  #   ```
  #
  #   Restore genome into a new evolvable:
  #
  #   ```ruby
  #   raw = File.read("champion.marshal")
  #   champion = YourEvolvable.new_evolvable
  #   champion.load_genome(raw)
  #   ```
  #
  class Serializer
    class << self
      def dump(data)
        klass.dump(data)
      end

      def load(data)
        klass.load(data)
      end

      private

      def klass
        @klass ||= Marshal
      end
    end
  end
end
