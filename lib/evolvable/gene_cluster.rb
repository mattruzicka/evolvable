# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Gene clusters group related genes into reusable components that can be applied
  #   to multiple evolvable classes. This promotes clean organization, eliminates
  #   naming conflicts, and simplifies gene access.
  #
  #   **Benefits:**
  #   - Reuse gene groups across multiple evolvables
  #   - Prevent name collisions via automatic namespacing
  #   - Treat clusters as structured subcomponents of a genome
  #   - Access all genes in a cluster with a single method call
  #
  #   The `ColorPaletteCluster` below defines a group of genes commonly used for styling themes:
  #
  #   ```ruby
  #   class ColorPaletteCluster
  #     include Evolvable::GeneCluster
  #
  #     gene :primary, type: 'ColorGene', count: 1
  #     gene :secondary, type: 'ColorGene', count: 1
  #     gene :accent, type: 'ColorGene', count: 1
  #     gene :neutral, type: 'ColorGene', count: 1
  #   end
  #   ```
  #
  #   Use the `cluster` macro to apply the cluster to your evolvable class:
  #
  #   ```ruby
  #   class Theme
  #     include Evolvable
  #
  #     cluster :colors, type: ColorPaletteCluster
  #
  #     def inspect_colors
  #       colors.join(", ")
  #     end
  #   end
  #   ```
  #
  #   When a cluster is applied, its genes are automatically namespaced with the cluster name:
  #   - Access the full group: `theme.colors` → returns all genes in the colors cluster
  #   - Access individual genes: `theme.find_gene("colors-primary")`
  #
  # @see Evolvable::Gene
  # @see Evolvable::GeneSpace
  #
  module GeneCluster
    #
    # When included in a class, extends the class with ClassMethods and initializes
    # the cluster configuration. This is called automatically when you include
    # the GeneCluster module in your class.
    #
    # @param base [Class] The class that includes the GeneCluster module
    # @return [void]
    #
    def self.included(base)
      base.extend(ClassMethods)
      base.instance_variable_set(:@cluster_config, [])
    end

    #
    # Class methods added to classes that include Evolvable::GeneCluster
    #
    module ClassMethods
      #
      # Defines a gene in the cluster.
      # This is used internally by the cluster to define its component genes.
      #
      # @param name [Symbol] The name of the gene within the cluster
      # @param opts [Hash] Options for the gene (type, count, etc.)
      #
      def gene(name, **opts)
        @cluster_config << [name, opts]
      end

      #
      # Applies all genes in this cluster to the given evolvable class.
      # This is called automatically when using the `cluster` macro.
      #
      # @param evolvable_class [Class] The evolvable class to apply the cluster to
      # @param cluster_name [Symbol] The name to use for the cluster in the evolvable class
      # @param _ [Hash] Additional options (for future expansion)
      # @return [void]
      #
      def apply_cluster(evolvable_class, cluster_name, **_)
        @cluster_config.each do |name, kw|
          evolvable_class.gene("#{cluster_name}-#{name}", **kw, cluster: cluster_name)
        end
      end

      #
      # Ensures that subclasses inherit the cluster configuration.
      #
      # @param subclass [Class] The subclass that is inheriting from this class
      # @return [void]
      #
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@cluster_config, @cluster_config.dup)
      end
    end
  end
end