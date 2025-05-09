# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   The Community module provides a framework for managing multiple interrelated populations
  #   in a coordinated manner. This is essential for more complex simulations where different types
  #   of evolvables need to interact, such as predator-prey ecosystems, multi-agent systems, or
  #   layered optimization problems.
  #
  #   **Key Features**
  #
  #   - Define a community with multiple population types
  #   - Manage relationships between different evolvable types
  #   - Coordinate evolution across multiple populations
  #   - Access populations and instances through a unified interface
  #
  #   **Example Use Cases**
  #
  #   - **Ecosystems**: Simulate interactions between plants, herbivores, and predators
  #   - **Multi-component Systems**: Design systems where components evolve together
  #   - **Layered Optimization**: Solve problems with different optimization levels
  #
  # @example Creating a simple ecosystem
  #   class Ecosystem
  #     include Evolvable::Community
  #
  #     evolvable_community plant: Plant,
  #                         animal: Animal
  #   end
  #
  #   # Create and use the ecosystem
  #   ecosystem = Ecosystem.new_community
  #   ecosystem.plant    # Returns a plant
  #   ecosystem.animal   # Returns an animal
  #
  module Community
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Creates a new instance of the community
      # @return [Object] A new community instance
      def new_community
        initialize_community
      end

      # Initializes a new community instance
      # This method exists as a hook for classes that include this module to override
      # and customize the community instantiation process.
      # @return [Object] A new community instance
      def initialize_community
        new
      end

      def load_community(data)
        Serializer.load(data)
      end

      attr_accessor :community_config

      # Configures a class as an evolvable community with specified populations
      # @param community_config [Hash] A hash mapping names to population classes
      # @return [void]
      def evolvable_community(community_config)
        self.community_config = community_config
        community_config.each_key do |name|
          method_name = name.to_sym
          define_method(method_name) do
            instance_variable_get("@#{method_name}") || instance_variable_set("@#{method_name}", find_or_new_evolvable(method_name))
          end
        end
      end

      # Returns a hash of population instances by name
      # @return [Hash] A hash mapping names to population instances
      def populations_by_name
        @populations_by_name ||= community_config.inject({}) do |hash, (name, population_klass)|
          hash[name.to_sym] = population_klass.new_population(size: 0)
          hash
        end
      end

      # Adds a population to the community
      # @param name [String, Symbol] The name of the population
      # @param population [Object] The population instance
      # @return [Object] The added population
      def add_population(name, population)
        populations_by_name[name.to_sym] = population
      end
    end

    # Returns a hash of population instances by name
    # @return [Hash] A hash mapping names to population instances
    def populations_by_name
      @populations_by_name ||= self.class.populations_by_name.dup
    end

    # Resets the populations hash to an empty hash
    # @return [Hash] An empty hash
    def reset_populations
      @populations_by_name = {}
    end

    # Adds a population to the community
    # @param name [String, Symbol] The name of the population
    # @param population [Object] The population instance
    # @return [Object] The added population
    def add_population(name, population)
      populations_by_name[name.to_sym] = population
    end

    # Finds a population by name
    # @param name [String, Symbol] The name of the population
    # @return [Object, nil] The population instance or nil if not found
    def find_population(name)
      populations_by_name[name.to_sym]
    end

    # Finds an evolvable instance by name
    # @param name [String, Symbol] The name of the evolvable
    # @return [Object, nil] The evolvable instance or nil if not found
    def find_evolvable(name)
      evolvables_by_name[name.to_sym]
    end

    # Finds an existing evolvable instance by name or creates a new one
    # @param name [String, Symbol] The name of the evolvable
    # @return [Object] The existing or new evolvable instance
    def find_or_new_evolvable(name)
      find_evolvable(name) || new_evolvable(name)
    end

    # Creates a new evolvable instance from the corresponding population
    # @param name [String, Symbol] The name of the evolvable
    # @return [Object] The new evolvable instance
    def new_evolvable(name)
      evolvables_by_name[name.to_sym] = find_population(name).new_evolvable
    end

    # Adds an evolvable instance to the community
    # @param name [String, Symbol] The name of the evolvable
    # @param evolvable [Object] The evolvable instance
    # @return [Object] The added evolvable
    def add_evolvable(name, evolvable)
      evolvables_by_name[name.to_sym] = evolvable
    end

    # Returns a hash of evolvable instances by name
    # @return [Hash] A hash mapping names to evolvable instances
    def evolvables_by_name
      @evolvables_by_name ||= {}
    end

    # Resets the evolvables hash to an empty hash
    # @return [Hash] An empty hash
    def reset_evolvables
      @evolvables_by_name = {}
    end
  end
end