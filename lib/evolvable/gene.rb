# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Genes are the building blocks of evolvable objects, encapsulating individual characteristics
  #   that can be combined and mutated during evolution. Each gene represents a trait or behavior
  #   that can influence an evolvable's performance.
  #
  #   **Creating Gene Classes**
  #
  #   When defining gene classes, you need to:
  #   1. Include the Evolvable::Gene module
  #   2. Define how the gene's value is determined
  #   3. Optionally override the combine method for custom combination behavior
  #
  #   **Design Patterns**
  #
  #   Effective gene design follows several patterns:
  #
  #   - **Immutability**: Gene values should be initialized once and cached. Use `@value ||= compute_value`
  #     pattern to ensure consistency
  #   - **Self-Contained**: Genes should encapsulate their own logic and data
  #   - **Composable**: Complex genes can be built from combinations of other genes
  #   - **Domain-Specific**: Genes should directly represent the domain
  #
  #   **Common Gene Types**
  #
  #   - **Numeric Genes**: Represent quantities, measurements, or probabilities
  #   - **Selection Genes**: Choose from a fixed set of options
  #   - **Boolean Genes**: Represent binary choices
  #   - **Structural Genes**: Control the structure or architecture of a solution
  #   - **Parameter Genes**: Configure parameters for algorithms or processes
  #
  #   Related sections:
  #   - See [Gene Space](#gene-space) for how genes are organized
  #   - See [Gene Clusters](#gene-clusters) for grouping related genes
  #   - See [Combination](#combination) for how genes are combined
  #
  # @example
  #   # A simple example showing gene definition and usage
  #   class BehaviorGene
  #     include Evolvable::Gene
  #
  #     def self.behaviors
  #       @behaviors ||= %w[explore gather attack defend build]
  #     end
  #
  #     def behavior
  #       @behavior ||= self.class.behaviors.sample
  #     end
  #
  #     # Custom combination that creates a new behavior based on parents
  #     def self.combine(gene_a, gene_b)
  #       new_gene = new
  #       # In a real implementation, this might combine behaviors
  #       # or choose based on some logic
  #       new_gene.instance_variable_set(:@behavior, [gene_a.behavior, gene_b.behavior].sample)
  #       new_gene
  #     end
  #   end
  #
  #   # Use the gene in an evolvable class
  #   class Robot
  #     include Evolvable
  #
  #     gene :behaviors, type: BehaviorGene, count: 3..5
  #     gene :speed, type: SpeedGene, count: 1
  #     gene :energy, type: EnergyGene, count: 1
  #
  #     def fitness
  #       # In a real implementation, this would run a simulation
  #       # and return a score based on the robot's performance
  #       run_simulation
  #     end
  #
  #     def to_s
  #       "Robot with behaviors: #{behaviors.map(&:behavior).join(', ')}"
  #     end
  #   end
  #
  #   # Create and evolve a population
  #   population = Robot.new_population(
  #     size: 50,
  #     mutation: { probability: 0.2 }
  #   )
  #
  #   # Evolve for 20 generations
  #   population.evolve(count: 20)
  #
  #   # Get the best robot
  #   best_robot = population.best_evolvable
  #   puts "Best robot: #{best_robot}"
  #

  module Gene
    #
    # When included in a class, extends the class with ClassMethods.
    # Gene classes should include this module to participate in the evolutionary process.
    #
    # @param base [Class] The class that includes the Gene module
    #
    def self.included(base)
      base.extend(ClassMethods)
    end

    #
    # Class methods added to classes that include Evolvable::Gene.
    # These methods enable gene-level behaviors like combination during evolution.
    #
    module ClassMethods
      #
      # Sets the unique key for this gene type.
      # The key is typically set automatically when using the `gene` macro.
      #
      # @param val [Symbol] The key to identify this gene type
      #
      def key=(val)
        @key = val
      end

      #
      # Returns the unique key for this gene type.
      #
      # @return [Symbol] The key that identifies this gene type
      #
      def key
        @key
      end

      #
      # Combines two genes to produce a new gene during the combination phase.
      # By default, randomly selects one of the two genes.
      # Override this method in your gene class to implement custom combination behavior.
      #
      # @example
      #   # Custom gene combination that averages two numeric genes
      #   def self.combine(gene_a, gene_b)
      #     new_gene = new
      #     new_gene.instance_variable_set(:@value, (gene_a.value + gene_b.value) / 2)
      #     new_gene
      #   end
      #
      # @param gene_a [Evolvable::Gene] The first gene to combine
      # @param gene_b [Evolvable::Gene] The second gene to combine
      # @return [Evolvable::Gene] A new gene resulting from the combination
      #
      def combine(gene_a, gene_b)
        [gene_a, gene_b].sample
      end
    end

    #
    # The evolvable instance that this gene belongs to.
    # Used for accessing other genes or evolvable properties.
    #
    # @return [Evolvable] The evolvable instance this gene is part of
    #
    attr_accessor :evolvable

    #
    # Returns the unique key for this gene instance.
    # Delegates to the class-level key.
    #
    # @return [Symbol] The key that identifies this gene type
    #
    def key
      self.class.key
    end
  end
end
