# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Genes are the building blocks of evolvable objects, encapsulating individual characteristics
  #   that can be combined and mutated during evolution. Each gene represents a trait or behavior
  #   that can influence an evolvable's performance.
  #
  #   **To define a gene class:**
  #   1. Include the `Evolvable::Gene` module
  #   2. Define how the gene's value is determined
  #
  #   ```ruby
  #   class BehaviorGene
  #     include Evolvable::Gene
  #
  #     def value
  #       @value ||= %w[explore gather attack defend build].sample
  #     end
  #   end
  #   ```
  #
  #   Then use it in an evolvable class:
  #
  #   ```ruby
  #   class Robot
  #     include Evolvable
  #
  #     gene :behaviors, type: BehaviorGene, count: 3..5
  #     gene :speed, type: SpeedGene, count: 1
  #
  #     def fitness
  #       run_simulation(behaviors: behaviors.map(&:value), speed: speed.value)
  #     end
  #   end
  #   ```
  #
  #   **Gene Count**
  #
  #   You can control how many copies of a gene are created using the `count:` parameter:
  #
  #   - `count: 1` (default) creates a single instance.
  #   - A numeric value (e.g. `count: 5`) creates a fixed number of genes using `RigidCountGene`.
  #   - A range (e.g. `count: 2..8`) creates a variable number of genes using `CountGene`, allowing the count to evolve over time.
  #
  #   Evolves melody length:
  #
  #   ```ruby
  #   gene :notes, type: NoteGene, count: 4..12
  #   ```
  #
  #   **Custom Combination**
  #
  #   By default, the `combine` method randomly picks one of the two parent genes.
  #   A gene class can implement custom behavior by overriding `.combine`.
  #
  #   ```ruby
  #   class SpeedGene
  #     include Evolvable::Gene
  #
  #     def self.combine(gene_a, gene_b)
  #       new_gene = new
  #       new_gene.value = (gene_a.value + gene_b.value) / 2
  #       new_gene
  #     end
  #
  #     attr_writer :value
  #
  #     def value
  #       @value ||= rand(1..100)
  #     end
  #   end
  #   ```
  #
  #   **Design Patterns**
  #
  #   Effective gene design typically follows these principles:
  #
  #   - **Immutability**: Cache values after initial sampling (e.g., `@value ||= ...`)
  #   - **Self-Contained**: Genes should encapsulate their logic and state
  #   - **Composable**: You can build complex structures using multiple genes or clusters
  #   - **Domain-Specific**: Genes should map directly to your problem’s traits or features
  #
  #   Genes come in various types, each representing different aspects of a solution.
  #   Common examples include numeric genes for quantities, selection genes for choices
  #   from sets, boolean genes for binary decisions, structural genes for architecture,
  #   and parameter genes for configuration settings.
  #
  # @see Evolvable::GeneSpace
  # @see Evolvable::GeneCluster
  # @see Evolvable::GeneCombination
  # @see Evolvable::CountGene
  # @see Evolvable::RigidCountGene
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
      # By default, randomly picks one of the two parent genes.
      #
      # Override this method in your gene class to implement custom combination behavior.
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
