# Evolvable 🧬

[![Gem Version](https://badge.fury.io/rb/evolvable.svg)](https://badge.fury.io/rb/evolvable)

**Code Version: 2.0.0** (unreleased)

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

Evolvable is designed to make creative, object‑oriented representations first‑class citizens. That means the same API that tunes numbers can evolve music, UI layouts, or game content just as naturally.

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
* [Documentation](https://mattruzicka.github.io/evolvable)


## Installation

Add [gem "evolvable"](https://rubygems.org/gems/evolvable) to your Gemfile and run `bundle install` or install it yourself with: `gem install evolvable`

**Ruby Compatibility:** Evolvable officially supports Ruby 3.0 and higher.

## Getting Started

The evolutionary process works through these components:
  1. **Populations**: Groups of the "evolvable" instances you define
  2. **Genes**: Ruby objects that cache data for evolvables
  3. **Evaluation**: Sorts evolvables by fitness
  4. **Evolution**: Selection, combination, and mutation to generate new evolvables

Quick start:
  1. Include `Evolvable` in your Ruby class
  2. Define genes with the macro-style `gene` method
  3. Have the `#fitness` method return a numeric value
  4. Initialize a population and evolve it

Example population of "shirts" with various colors, buttons, and collars.

  ```ruby
  # Step 1
  class Shirt
    include Evolvable

    # Step 2
    gene :color, type: ColorGene # count: 1 default
    gene :buttons, type: ButtonGene, count: 0..10 # Builds an array of genes that can vary in size
    gene :collar, type: CollarGene, count: 0..1 # Collar optional

    # Step 3
    attr_accessor :fitness
  end

  # Step 4
  population = Shirt.new_population(size: 10)
  population.evolvables.each { |shirt| shirt.fitness = tried_it_on_score }
  ```

You are free to tailor the genes to your needs and "try it on" yourself.

The `ColorGene` could be as simple as this:

  ```ruby
  class ColorGene
    include Evolvable::Gene

    def to_s
      @to_s ||= %w[red green blue].sample
    end
  end
  ```

Not into shirts?

Here's a [Hello World](https://github.com/mattruzicka/evolvable/blob/main/exe/hello_evolvable_world) command line demo.


## Concepts

Evolvable is built on these core concepts:
- **Genes**: Encapsulate evolving traits and behaviors
- **Genomes**: Genes organized in a searchable structure
- **Evolvables**: Composable Ruby objects that delegate to genes
- **Populations**: Groups of evolvables that evolve together
- **Evaluation**: Fitness scoring to rank solutions
- **Evolution**: Three-phase process (Selection → Combination → Mutation)
- **Communities**: Encapsulate evolvable populations

The library provides default implementations while allowing custom components to adapt to specific problem domains.

## Genes

Genes are the building blocks of evolvable objects, encapsulating individual characteristics
that can be combined and mutated during evolution. Each gene represents a trait or behavior
that can influence an evolvable's performance.

**Creating Gene Classes**

When defining gene classes, you need to:
1. Include the Evolvable::Gene module
2. Define how the gene's value is determined
3. Optionally override the combine method for custom combination behavior

**Design Patterns**

Effective gene design follows several patterns:

- **Immutability**: Gene values should be initialized once and cached. Use `@value ||= compute_value`
  pattern to ensure consistency
- **Self-Contained**: Genes should encapsulate their own logic and data
- **Composable**: Complex genes can be built from combinations of other genes
- **Domain-Specific**: Genes should directly represent the domain

**Common Gene Types**

- **Numeric Genes**: Represent quantities, measurements, or probabilities
- **Selection Genes**: Choose from a fixed set of options
- **Boolean Genes**: Represent binary choices
- **Structural Genes**: Control the structure or architecture of a solution
- **Parameter Genes**: Configure parameters for algorithms or processes

Related sections:
- See [Gene Space](#gene-space) for how genes are organized
- See [Gene Clusters](#gene-clusters) for grouping related genes
- See [Combination](#combination) for how genes are combined


**Example**
```ruby
# A simple example showing gene definition and usage
class BehaviorGene
  include Evolvable::Gene

  def self.behaviors
    @behaviors ||= %w[explore gather attack defend build]
  end

  def behavior
    @behavior ||= self.class.behaviors.sample
  end

  # Custom combination that creates a new behavior based on parents
  def self.combine(gene_a, gene_b)
    new_gene = new
    # In a real implementation, this might combine behaviors
    # or choose based on some logic
    new_gene.instance_variable_set(:@behavior, [gene_a.behavior, gene_b.behavior].sample)
    new_gene
  end
end

# Use the gene in an evolvable class
class Robot
  include Evolvable

  gene :behaviors, type: BehaviorGene, count: 3..5
  gene :speed, type: SpeedGene, count: 1
  gene :energy, type: EnergyGene, count: 1

  def fitness
    # In a real implementation, this would run a simulation
    # and return a score based on the robot's performance
    run_simulation
  end

  def to_s
    "Robot with behaviors: #{behaviors.map(&:behavior).join(', ')}"
  end
end

# Create and evolve a population
population = Robot.new_population(
  size: 50,
  mutation: { probability: 0.2 }
)

# Evolve for 20 generations
population.evolve(count: 20)

# Get the best robot
best_robot = population.best_evolvable
puts "Best robot: #{best_robot}"
```


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Gene)

## Populations

Populations orchestrate the evolutionary process through four key components:

1. **Evaluation**: Ranks instances by fitness
2. **Selection**: Chooses parents for combination
3. **Combination**: Creates offspring from parents
4. **Mutation**: Adds genetic diversity

**Features**

- Easy configuration via parameters
- Lifecycle hooks (`before_evaluation`, `before_evolution`, `after_evolution`)
- Progress tracking with `best_evolvable`
- Goal-based or generation-count evolution
- Serialization for saving/restoring

**Configuration**

```ruby
population = MyEvolvable.new_population(
  size: 50,                            # Population size
  evaluation: { maximize: true },      # Fitness goal
  selection: { size: 10 },             # Parent selection count
  mutation: { probability: 0.2 }       # Mutation rate
)

# Run evolution
population.evolve(count: 20)           # For 20 generations
# or
population.evolve(goal_value: 100)     # Until fitness goal reached
```


**Example**
```ruby
# Track evolution progress over generations
population = Shape.new_population(size: 30)

10.times do |i|
  population.evolve(count: 1)
  best = population.best_evolvable
  puts "Generation #{i}: Best fitness = #{best.fitness}"
end

# Get and use the best solution
best_shape = population.best_evolvable
puts "Final solution: #{best_shape}"
```


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Population)

## Evaluation

Evaluation determines how evolvables are ranked based on their fitness scores and provides
mechanisms to specify evolutionary goals (maximize, minimize, or equalize).

**How It Works**

1. Your evolvable class defines a `#fitness` method that returns a numeric score
2. The evaluation's goal determines how this score is interpreted:
   - `maximize`: Higher values are better (default)
   - `minimize`: Lower values are better
   - `equalize`: Values closer to target are better
3. During evolution, evolvables are sorted based on the goal's interpretation
4. Evolution can stop when an evolvable reaches a specified goal value

**Related Sections**
- See [Population](#populations) for how evaluation fits into evolution
- See [Selection](#selection) for how evaluated individuals are chosen


**Example**
```ruby
# Define an evolvable with a fitness function
class Robot
  include Evolvable

  gene :speed, type: SpeedGene, count: 1
  gene :sensors, type: SensorGene, count: 1..5

  def fitness
    # Calculate fitness based on speed and sensor quality
    score = speed.value * 10
    score += sensors.sum(&:accuracy) * 5
    score -= sensors.size > 3 ? (sensors.size - 3) * 10 : 0 # Penalty for too many sensors
    score
  end
end

# Different goal types

# 1. Maximize (higher is better)
robots = Robot.new_population(evaluation: { maximize: true })
robots.evolve(goal_value: 100)  # Until fitness reaches 100+

# 2. Minimize (lower is better)
errors = ErrorModel.new_population(evaluation: { minimize: true })
errors.evolve(goal_value: 0.01)  # Until error rate reaches 0.01 or less

# 3. Equalize (closer to target is better)
targets = TargetMatcher.new_population(evaluation: { equalize: 42 })
targets.evolve(goal_value: 42)  # Until we match the target value
```


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Evaluation)

## Goals

Goals define the success criteria for evolution. They allow you to specify what your
population is evolving toward, whether it's maximizing a value, minimizing a value,
or reaching a specific target value.

Evolvable provides three built-in goal types:
- **MaximizeGoal**: Higher fitness values are better (e.g., scoring more points)
- **MinimizeGoal**: Lower fitness values are better (e.g., reducing errors)
- **EqualizeGoal**: Values closer to a target are better (e.g., matching a pattern)

Each goal type influences:
1. How evolvables are ranked during evaluation
2. Which evolvables are selected as parents
3. When to stop evolving if a goal value is reached

**Custom Goals**

You can create custom goals by subclassing Goal and implementing:
- `evaluate(evolvable)`: Returns a value used to rank evolvables
- `met?(evolvable)`: Returns true when the goal is reached


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

[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Goal)

## Evolution

After a population's instances are evaluated, they undergo evolution.
The default evolution object is composed of selection,
combination, and mutation objects and applies them as operations to
a population's evolvables in that order.

Each evolutionary operation can be customized individually, allowing you to
fine-tune the evolutionary process to fit your specific problem domain.


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Evolution)

## Selection

The selection object assumes that a population's evolvables have already
been sorted by the evaluation object. It selects "parent" evolvables to
undergo combination and thereby produce the next generation of evolvables.

Only two evolvables are selected as parents for each generation by default.
The selection size is configurable.

```ruby
# Configure selection size
population = MyEvolvable.new_population(
  selection: { size: 3 }  # Select top 3 performers
)
```

You can also assign selected evolvables:

```ruby
population.selected_evolvables = [evolvable1, evolvable2]
```
or skip to evolving them:

```ruby
population.evolve_selected([evolvable1, evolvable2])
```

This allows for custom selection strategies beyond the built-in methods.


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Selection)

## Combination

Combination generates new evolvable instances by combining the genes of selected instances.
You can think of it as a mixing of parent genes from one generation to
produce the next generation.

You may choose from a selection of combination objects or implement your own.
The default combination object is `Evolvable::GeneCombination`.

This implementation enables individual gene types to define their own
combination behaviors through the Gene.combine class method, giving you
fine-grained control over how different gene types are combined.


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Combination)

## Crossover Strategies

**Point Crossover**

PointCrossover implements single and multi-point crossover, a common recombination
strategy in genetic algorithms. It works by selecting random points in the gene sequence
and exchanging genetic material between those points.

In single-point crossover (the default), one position is chosen at random, and all genes
beyond that point are swapped between parents. In multi-point crossover, multiple
positions are chosen, and segments between consecutive points are alternately swapped.

This strategy:
- Preserves segments of good solutions
- Enables exploration of different combinations of traits
- Is particularly effective when related genes are close together

Configuration:
```ruby
population = MyEvolvable.new_population(
  combination: Evolvable::PointCrossover.new(points_count: 2)  # Two-point crossover
)

# Or modify an existing population
population.combination = Evolvable::PointCrossover.new(points_count: 3)
```


**Uniform Crossover**

UniformCrossover randomly selects genes from either parent with equal probability
for each gene position. Unlike point crossover, there are no "chunks" of genes preserved
from either parent - each gene is chosen independently.

This strategy:
- Provides maximum mixing of genetic material
- Better handles problems where gene ordering isn't important
- Often performs well on problems with complex interdependencies

Uniform crossover is particularly effective when good solutions have traits that are
widely distributed throughout the genome rather than clustered together.

Configuration:
```ruby
population = MyEvolvable.new_population(
  combination: Evolvable::UniformCrossover.new
)
```


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/PointCrossover)

## Mutation

Mutation introduces genetic diversity by replacing genes with newly initialized ones.
This is crucial for exploring the solution space and preventing premature convergence.

Two key parameters control mutation:
- `probability`: Chance of an individual being mutated (0.0-1.0)
- `rate`: Portion of genes to mutate in affected individuals (0.0-1.0)

Common strategies:
- Higher rates early (exploration phase)
- Lower rates later (exploitation/refinement phase)


**Example**
```ruby
# Start with high mutation for exploration
population = MyEvolvable.new_population(
  mutation: { probability: 0.4, rate: 0.2 }
)

# Later, reduce for fine-tuning
population.mutation.probability = 0.1
population.mutation.rate = 0.05
```


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Mutation)

## Gene Space

The gene space defines the genetic structure of evolvable classes - a blueprint
for creating and managing genes.

**Two Key Gene Count Types**

1. **Fixed Count**: When you specify a single number or default
   ```ruby
   gene :color, type: ColorGene  # Default count: 1
   ```

2. **Variable Count**: When you specify a range
   ```ruby
   gene :skills, type: SkillGene, count: 1..5  # Can evolve between 1-5 skills
   ```

**Benefits**

- Declarative model definition
- Automatic gene management
- Self-evolving structure (with ranges)
- Consistent instance initialization

Related sections:
- See [Genes](#genes) for defining individual gene classes
- See [Gene Clusters](#gene-clusters) for organizing related genes
- See [Population](#populations) for using gene spaces in populations


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

[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/GeneSpace)

## Count Genes

**Dynamic Count Genes**

The CountGene class handles the dynamic count of genes in evolvable instances.
When a gene is defined with a range for `count:` (e.g., `count: 2..8`), a CountGene
is created to manage this count, allowing the number of genes to evolve over
successive generations.


**Fixed Count Genes**

The RigidCountGene class manages fixed gene counts in evolvable instances.
Unlike CountGene, the RigidCountGene maintains a constant number of genes
that doesn't change during evolution. This is used when a gene is defined
with a fixed integer for `count:` (e.g., `count: 5`).


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/CountGene)

## Genomes

The Genome class represents the complete genetic blueprint of an evolvable instance.
It stores and manages all genes organized by their keys, providing methods to access,
manipulate, and serialize genetic information.

A genome consists of:
- Gene configurations organized by key
- Count genes that determine how many of each gene type exists
- Methods to find and manipulate genes

The genome serves as the intermediary between the gene space (the definition)
and the actual gene instances (the implementation).

Related sections:
- See [Gene Space](#gene-space) for how genomes are created
- See [Combination](#combination) for how genomes are combined
- See [Genes](#genes) for the building blocks that make up genomes


[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Genome)

## Gene Clusters

Gene clusters group related genes into reusable components that can be applied
to multiple evolvable classes.

When applied, genes are automatically namespaced with the cluster name:
- Access as a group: `evolvable.styling` (returns all styling genes)
- Access individually: `evolvable.find_gene("styling-color")`

This provides:
- Clean organization of related genes (styling, physics, etc.)
- Prevention of name conflicts
- Simplified access to gene groups

Related sections:
- See [Genes](#genes) for defining individual gene classes
- See [Gene Space](#gene-space) for how clusters integrate with the gene space


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

[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/GeneCluster)

## Community

The Community module provides a framework for managing multiple interrelated populations
in a coordinated manner. This is essential for more complex simulations where different types
of evolvables need to interact, such as predator-prey ecosystems, multi-agent systems, or
layered optimization problems.

**Key Features**

- Define a community with multiple population types
- Manage relationships between different evolvable types
- Coordinate evolution across multiple populations
- Access populations and instances through a unified interface

**Example Use Cases**

- **Ecosystems**: Simulate interactions between plants, herbivores, and predators
- **Multi-component Systems**: Design systems where components evolve together
- **Layered Optimization**: Solve problems with different optimization levels


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

[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Community)

## Serialization

The Serializer provides a way to save and restore the state of populations
and evolvable instances. By default, it uses Ruby's built-in Marshal class
to serialize data.

Serialization is useful for:
- Saving the progress of a long-running evolution
- Storing champion solutions for later use
- Transferring evolved populations between systems
- Creating checkpoints to revert to if needed

Evolvable provides serialization methods on both Population and individual
evolvable instances, all of which use this Serializer internally.

```ruby
# Save a population to a file
population = MyEvolvable.new_population
population.evolve(count: 100)

# Save state
serialized_data = population.dump
File.write('evolved_population.dat', serialized_data)

# Later, load the state
data = File.read('evolved_population.dat')
restored_population = Population.load(data)

# Continue evolution from saved point
restored_population.evolve(count: 100)
```


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

[Full Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Serializer)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattruzicka/evolvable.