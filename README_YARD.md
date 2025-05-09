# Evolvable 🧬

[![Gem Version](https://badge.fury.io/rb/evolvable.svg)](https://badge.fury.io/rb/evolvable)

**Code Version: {@string Evolvable::VERSION}** (unreleased)

🚧 **The README and Documentation are still evolving**

Evolvable is a Ruby gem that brings genetic algorithms to Ruby objects through simple, flexible APIs. Define genes, implement fitness criteria, and let evolution discover optimal solutions through selection, combination, and mutation.

Perfect for optimization problems, creative content generation, machine learning, and simulating complex systems.

## Why Evolvable?

Evolvable is ideal when the solution space is too large or complex for brute-force methods. Instead of hardcoding solutions, you define constraints and let evolution discover optimal configurations over time.

**The Evolvable Approach:**
- Explore vast solution spaces efficiently without examining every possibility
- Discover novel solutions that might not be obvious to human designers
- Adapt to changing conditions through continuous evolution
- Balance diverse objectives with communities of different populations
- Integrate evolutionary concepts directly into your Ruby object model
- Generate creative content like music, art, and text, not just numerical optimization

Whether you're optimizing parameters, generating creative content, or simulating complex systems, Evolvable provides a natural, object-oriented approach to evolutionary algorithms.

## Creative Applications

Evolvable treats creative, object-oriented representations as first-class citizens. The same API that optimizes numeric parameters can evolve music compositions, UI layouts, or game content with equal fluency.

Creative applications of Evolvable include:
- **Generative art**: Evolve visual compositions based on aesthetic criteria
- **Music composition**: Create melodies, chord progressions, and rhythms
- **Game design**: Generate levels, characters, or game mechanics
- **Natural language**: Evolve text with specific tones, styles, or constraints
- **UI/UX design**: Discover intuitive layouts and color schemes

## Table of Contents
* [Installation](#installation)
* [Getting Started](#getting-started)
* [Concepts](#concepts)
* [Genes](#genes)
* [Populations](#populations)
* [Evaluation](#evaluation)
* [Goals](#goals)
* [Evolution](#evolution)
* [Selection](#selection)
* [Combination](#combination)
* [Crossover Strategies](#crossover-strategies)
* [Mutation](#mutation)
* [Gene Space](#gene-space)
* [Count Genes](#count-genes)
* [Genomes](#genomes)
* [Gene Clusters](#gene-clusters)
* [Community](#community)
* [Serialization](#serialization)
* [Documentation]({@string Evolvable::DOC_URL})


## Installation

Add [gem "evolvable"](https://rubygems.org/gems/evolvable) to your Gemfile and run `bundle install` or install it yourself with: `gem install evolvable`

**Ruby Compatibility:** Evolvable officially supports Ruby 3.0 and higher.

## Getting Started

{@readme Evolvable}

## Concepts

Evolvable is built on these core concepts:
- **Genes**: Ruby objects that cache data for evolvables
- **Evolvables**: Your Ruby classes that include "Evolvable" and delegate to genes
- **Populations**: Groups of evolvables instances that evolve together
- **Evaluation**: Sorts evolvables by fitness
- **Evolution**: Selection → Combination → Mutation to generate new evolvables
- **Communities**: Encapsulate evolvable populations

The framework offers built-in implementations while allowing domain-specific customization through its extensible and swapable components.

## Genes

{@readme Evolvable::Gene}

[Gene Documentation]({@string Evolvable::DOC_URL}/Evolvable/Gene)

## Populations

{@readme Evolvable::Population}

**Example**
{@example Evolvable::Population}

[Population Documentation]({@string Evolvable::DOC_URL}/Evolvable/Population)

## Evaluation

{@readme Evolvable::Evaluation}

**Example**
{@example Evolvable::Evaluation}

[Evaluation Documentation]({@string Evolvable::DOC_URL}/Evolvable/Evaluation)

## Goals

{@readme Evolvable::Goal}

**Example**
```ruby
# Using different goal types
class RuleOptimizer
  include Evolvable

  gene :rules, type: RuleGene, count: 5..20

  def fitness
    # Calculate fitness based on rule effectiveness
    accuracy = calculate_accuracy
    complexity_penalty = rules.count * 0.5
    accuracy - complexity_penalty
  end
end

# Configure populations with different goals
max_population = RuleOptimizer.new_population(
  evaluation: { maximize: true }  # Find most effective rules
)

min_population = RuleOptimizer.new_population(
  evaluation: { minimize: 0.1 }   # Minimize error rate to 10%
)

equal_population = RuleOptimizer.new_population(
  evaluation: { equalize: 50 }    # Reach exactly 50% performance
)

# Stopping evolution when goal is reached
max_population.evolve(goal_value: 95)  # Evolve until 95% accuracy
```

[Goal Documentation]({@string Evolvable::DOC_URL}/Evolvable/Goal)

## Evolution

{@readme Evolvable::Evolution}

[Evolution Documentation]({@string Evolvable::DOC_URL}/Evolvable/Evolution)

## Selection

{@readme Evolvable::Selection}

[Selection Documentation]({@string Evolvable::DOC_URL}/Evolvable/Selection)

## Combination

{@readme Evolvable::GeneCombination}

[Combination Documentation]({@string Evolvable::DOC_URL}/Evolvable/Combination)

## Crossover Strategies

**Point Crossover**

{@readme Evolvable::PointCrossover}

**Uniform Crossover**

{@readme Evolvable::UniformCrossover}

[PointCrossover Documentation]({@string Evolvable::DOC_URL}/Evolvable/PointCrossover)

## Mutation

{@readme Evolvable::Mutation}

**Example**
{@example Evolvable::Mutation}

[Mutation Documentation]({@string Evolvable::DOC_URL}/Evolvable/Mutation)

## Gene Space

{@readme Evolvable::GeneSpace}

**Example**
```ruby
class MusicComposer
  include Evolvable

  # Define basic musical genes
  gene :melody, type: MelodyGene, count: 1
  gene :harmony, type: HarmonyGene, count: 1
  gene :rhythm, type: RhythmGene, count: 1

  # Group audio effects into a cluster for easier handling
  gene :reverb, type: ReverbGene, count: 0..1, cluster: :effects
  gene :delay, type: DelayGene, count: 0..1, cluster: :effects
  gene :distortion, type: DistortionGene, count: 0..1, cluster: :effects
  gene :flanger, type: FlangerGene, count: 0..1, cluster: :effects

  def play
    # Access genes directly
    puts "Playing melody: #{melody}"

    # Or access gene clusters as collections
    puts "With effects: #{effects.map(&:name).join(', ')}"
  end

  def fitness
    # Evaluate fitness based on musical theory and constraints
    melody_score = melody.consonance_with(harmony)
    structure_balance = structure.count > 1 ? 1.0 : 0.5
    effect_complexity = [1.0, effects.count * 0.2].min

    melody_score * structure_balance * effect_complexity
  end
end

# Access genes and clusters
composer = MusicComposer.new_evolvable
composer.reverb                # Access a specific gene
composer.effects               # Access all genes in the effects cluster
composer.effects.count         # Number of effect genes
composer.structure.first.type  # Access a property of the first structure gene
```

[GeneSpace Documentation]({@string Evolvable::DOC_URL}/Evolvable/GeneSpace)

## Count Genes

**Dynamic Count Genes**

{@readme Evolvable::CountGene}

**Fixed Count Genes**

{@readme Evolvable::RigidCountGene}

[CountGene Documentation]({@string Evolvable::DOC_URL}/Evolvable/CountGene)

## Genomes

{@readme Evolvable::Genome}

[Genome Documentation]({@string Evolvable::DOC_URL}/Evolvable/Genome)

## Gene Clusters

{@readme Evolvable::GeneCluster}

**Example**
```ruby
# Define a reusable cluster for visual styling
module Evolvable::UI
  class StylingCluster
    include Evolvable::GeneCluster

    gene :background_color, type: 'UI::ColorGene', count: 1
    gene :text_color, type: 'UI::ColorGene', count: 1
    gene :border_color, type: 'UI::ColorGene', count: 0..1
    gene :border_width, type: 'UI::SizeGene', count: 0..1
    gene :border_radius, type: 'UI::RadiusGene', count: 0..1
    gene :shadow, type: 'UI::ShadowGene', count: 0..1
  end
end

# Use the styling cluster in multiple UI components
class Button
  include Evolvable

  # Apply the styling cluster
  cluster :styling, type: Evolvable::UI::StylingCluster

  # Button-specific genes
  gene :size, type: SizeGene, count: 1
  gene :text, type: TextGene, count: 1

  def render
    puts "Button with #{text}"
    puts "Background: #{styling.background_color.hex_code}"
    puts "Border: #{styling.border_width&.value || 0}px"
  end

  def fitness
    # Evaluate based on design principles and constraints
    contrast = styling.text_color.contrast_with(styling.background_color)
    readability = text.length < 15 ? 1.0 : 0.7

    contrast * readability
  end
end

class Panel
  include Evolvable

  # Reuse the same styling cluster with a different name
  cluster :visual, type: Evolvable::UI::StylingCluster

  # Panel-specific genes
  gene :width, type: SizeGene, count: 1
  gene :height, type: SizeGene, count: 1
  gene :children, type: ComponentGene, count: 0..10

  def render
    puts "Panel #{width.value}x#{height.value}"
    puts "Background: #{visual.background_color.hex_code}"
    children.each(&:render)
  end
end
```

[GeneCluster Documentation]({@string Evolvable::DOC_URL}/Evolvable/GeneCluster)

## Community

{@readme Evolvable::Community}

**Example**
```ruby
# A complex ecosystem with multiple interacting species
class BiomeSimulation
  include Evolvable::Community

  evolvable_community plants: Plant,
                      herbivores: Herbivore,
                      carnivores: Carnivore

  def simulate_interactions(cycles = 1)
    cycles.times do
      # Plants grow based on environmental factors
      plants.each(&:grow)

      # Herbivores eat plants and may increase or decrease in population
      herbivores.each do |herbivore|
        herbivore.eat(plants.sample)
      end

      # Carnivores hunt herbivores
      carnivores.each do |carnivore|
        carnivore.hunt(herbivores.sample)
      end

      # Evolve all populations for one generation
      evolve_all
    end
  end

  def evolve_all
    populations_by_name.values.each do |population|
      population.evolve(count: 1)
    end
  end
end

# Initialize and use the simulation
biome = BiomeSimulation.new_community
biome.simulate_interactions(10)
```

[Community Documentation]({@string Evolvable::DOC_URL}/Evolvable/Community)

## Serialization

{@readme Evolvable::Serializer}

**Example**
```ruby
# Basic serialization and persistence
class EvolutionManager
  def save_champion(population, filename)
    champion = population.best_evolvable
    serialized = champion.dump_genome
    File.write(filename, serialized)
    puts "Champion saved with fitness: #{champion.fitness}"
  end

  def load_champion(evolvable_class, filename)
    serialized = File.read(filename)
    champion = evolvable_class.new_evolvable
    champion.load_genome(serialized)
    champion
  end

  def checkpoint_population(population, filename)
    serialized = population.dump
    File.write(filename, serialized)
    puts "Population checkpoint saved at generation #{population.evolutions_count}"
  end

  def restore_population(filename)
    serialized = File.read(filename)
    Evolvable::Population.load(serialized)
  end
end

# Usage
manager = EvolutionManager.new
population = MyEvolvable.new_population(size: 100)

# Run evolution for 50 generations with checkpoints
5.times do |i|
  population.evolve(count: 10)
  manager.checkpoint_population(population, "checkpoint_#{i}.dat")
  manager.save_champion(population, "champion_#{i}.dat")
end

# Restore from checkpoint
restored = manager.restore_population("checkpoint_3.dat")
```

[Serializer Documentation]({@string Evolvable::DOC_URL}/Evolvable/Serializer)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattruzicka/evolvable.