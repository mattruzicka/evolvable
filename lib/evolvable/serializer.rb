# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   The Serializer provides a way to save and restore the state of populations
  #   and evolvable instances. By default, it uses Ruby's built-in Marshal class
  #   to serialize data.
  #
  #   Serialization is useful for:
  #   - Saving the progress of a long-running evolution
  #   - Storing champion solutions for later use
  #   - Transferring evolved populations between systems
  #   - Creating checkpoints to revert to if needed
  #
  #   Evolvable provides serialization methods on both Population and individual
  #   evolvable instances, all of which use this Serializer internally.
  #
  #   ```ruby
  #   # Save a population to a file
  #   population = MyEvolvable.new_population
  #   population.evolve(count: 100)
  #
  #   # Save state
  #   serialized_data = population.dump
  #   File.write('evolved_population.dat', serialized_data)
  #
  #   # Later, load the state
  #   data = File.read('evolved_population.dat')
  #   restored_population = Population.load(data)
  #
  #   # Continue evolution from saved point
  #   restored_population.evolve(count: 100)
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
