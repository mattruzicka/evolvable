# frozen_string_literal: true

module Evolvable
  #
  # @readme
  #   Gene clusters provide a way to organize related genes into logical groups.
  #   These clusters can be defined as separate reusable components and applied
  #   to different evolvable classes, promoting modularity and code reuse.
  #
  #   Gene clusters are useful when you have groups of related genes that often
  #   appear together, such as visual styling properties, audio effects, or any
  #   collection of genes that function as a unit.
  #
  # @example
  #   # Define a reusable gene cluster for audio effects
  #   class EffectsCluster
  #     include Evolvable::GeneCluster
  #
  #     gene :reverb, type: 'ReverbGene', count: 0..1
  #     gene :delay, type: 'DelayGene', count: 0..1
  #     gene :distortion, type: 'DistortionGene', count: 0..1
  #     gene :flanger, type: 'FlangerGene', count: 0..1
  #   end
  #
  #   # Use the cluster in an evolvable class
  #   class MusicComposer
  #     include Evolvable
  #
  #     # Basic musical genes
  #     gene :melody, type: MelodyGene, count: 1
  #     gene :harmony, type: HarmonyGene, count: 1
  #
  #     # Apply the effects cluster
  #     cluster :effects, type: EffectsCluster
  #
  #     def play
  #       # The cluster can be accessed as a single unit
  #       puts "Playing with effects: #{effects.map(&:name).join(', ')}"
  #     end
  #   end
  #
  module GeneCluster
    # @private
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
      #
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@cluster_config, @cluster_config.dup)
      end
    end
  end
end