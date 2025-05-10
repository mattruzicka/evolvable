# Evolvable 🧬

[![Gem Version](https://badge.fury.io/rb/evolvable.svg)](https://badge.fury.io/rb/evolvable)

**Code Version: 2.0.0**

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

**Creative Applications**

Evolvable treats creative, object-oriented representations as first-class citizens. The same API that optimizes numeric parameters can evolve music compositions, UI layouts, or game content with equal fluency. Examples include:

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
* [Evolution](#evolution)
* [Selection](#selection)
* [Combination](#combination)
* [Mutation](#mutation)
* [Gene Clusters](#gene-clusters)
* [Community](#community)
* [Serialization](#serialization)
* [Documentation](https://mattruzicka.github.io/evolvable)


## Installation

Add [gem "evolvable"](https://rubygems.org/gems/evolvable) to your Gemfile and run `bundle install` or install it yourself with: `gem install evolvable`

**Ruby Compatibility:** Evolvable officially supports Ruby 3.0 and higher.

## Getting Started

**Quick start**:
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
population.evolvables.each { |shirt| shirt.fitness = style_rating }
```

You are free to tailor the genes to your needs and find a style that suits you.

The `ColorGene` could be as simple as this:

```ruby
class ColorGene
  include Evolvable::Gene

  def to_s
    @to_s ||= %w[red green blue].sample
  end
end
```

Shirts aren't your style?

Here's a [Hello World](https://github.com/mattruzicka/evolvable/blob/main/exe/hello_evolvable_world)
command line demo.


## Concepts

Evolvable is built on these core concepts:
- **Genes**: Ruby objects that represent traits or behaviors and are passed down during evolution.
- **Evolvables**: Your Ruby classes that include "Evolvable" and delegate to genes
- **Populations**: Groups of evolvables instances that evolve together
- **Evaluation**: Sorts evolvables by fitness
- **Evolution**: Selection → Combination → Mutation to generate new evolvables
- **Communities**: Encapsulate evolvable populations

The framework offers built-in implementations while allowing domain-specific customization through its extensible and swapable components.

## Genes

Genes are the building blocks of evolvable objects, encapsulating individual characteristics
that can be combined and mutated during evolution. Each gene represents a trait or behavior
that can influence an evolvable's performance.

**To define a gene class:**
1. Include the `Evolvable::Gene` module
2. Define how the gene's value is determined

```ruby
class BehaviorGene
  include Evolvable::Gene

  def value
    @value ||= %w[explore gather attack defend build].sample
  end
end
```

Then use it in an evolvable class:

```ruby
class Robot
  include Evolvable

  gene :behaviors, type: BehaviorGene, count: 3..5
  gene :speed, type: SpeedGene, count: 1

  def fitness
    run_simulation(behaviors: behaviors.map(&:value), speed: speed.value)
  end
end
```

**Gene Count**

You can control how many copies of a gene are created using the `count:` parameter:

- `count: 1` (default) creates a single instance.
- A numeric value (e.g. `count: 5`) creates a fixed number of genes using `RigidCountGene`.
- A range (e.g. `count: 2..8`) creates a variable number of genes using `CountGene`, allowing the count to evolve over time.

Evolves melody length:

```ruby
gene :notes, type: NoteGene, count: 4..12
```

**Custom Combination**

By default, the `combine` method randomly picks one of the two parent genes.
A gene class can implement custom behavior by overriding `.combine`.

```ruby
class SpeedGene
  include Evolvable::Gene

  def self.combine(gene_a, gene_b)
    new_gene = new
    new_gene.value = (gene_a.value + gene_b.value) / 2
    new_gene
  end

  attr_writer :value

  def value
    @value ||= rand(1..100)
  end
end
```

**Design Patterns**

Effective gene design typically follows these principles:

- **Immutability**: Cache values after initial sampling (e.g., `@value ||= ...`)
- **Self-Contained**: Genes should encapsulate their logic and state
- **Composable**: You can build complex structures using multiple genes or clusters
- **Domain-Specific**: Genes should map directly to your problem’s traits or features

Genes come in various types, each representing different aspects of a solution.
Common examples include numeric genes for quantities, selection genes for choices
from sets, boolean genes for binary decisions, structural genes for architecture,
and parameter genes for configuration settings.


[Gene Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Gene)

## Populations

Populations orchestrate the evolutionary process through four key components:

1. **Evaluation**: Sorts evolvable instances by fitness
2. **Selection**: Chooses parents for combination
3. **Combination**: Creates new evolvables from selected parents
4. **Mutation**: Introduces variation to maintain genetic diversity

**Features**:

Initialize a population with default or custom parameters:

```ruby
population = YourEvolvable.new_population(
  size: 50,
  evaluation: { equalize: 0 },
  selection: { size: 10 },
  mutation: { probability: 0.2, rate: 0.02 }
)
```

Or inject fully customized strategy objects:

```ruby
population = YourEvolvable.new_population(
  evaluation: Your::Evaluation.new,
  evolution: Your::Evolution.new,
  selection: Your::Selection.new,
  combination: Your::Combination.new,
  mutation: Your::Mutation.new
)
```

Evolve your population:

```ruby
population.evolve(count: 20)            # Run for 20 generations
population.evolve_to_goal               # Run until the current goal is met
population.evolve_to_goal(0.0)          # Run until a specific goal is met
population.evolve_forever               # Run indefinitely, ignoring any goal
population.evolve_selected([...])       # Use a custom subset of evolvables
```

Create new evolvables:

```ruby
new = population.new_evolvable
many = population.new_evolvables(count: 10)
with_genome = population.new_evolvable(genome: another.genome)
```

Customize the evolution lifecycle by implementing hooks:

```ruby
def self.before_evaluation(pop); end
def self.before_evolution(pop); end
def self.after_evolution(pop); end
```

Evaluate progress:

```ruby
best = population.best_evolvable if population.met_goal?
```


[Population Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Population)

## Evaluation

Evaluation sorts evolvables based on their fitness and provides mechanisms to
change the goal type and value (fitness goal). Goals define the success criteria
for evolution. They allow you to specify what your population is evolving toward,
whether it's maximizing a value, minimizing a value, or seeking a specific value.

**How It Works**

1. Your evolvable class defines a `#fitness` method that returns a
[Comparable](https://docs.ruby-lang.org/en//3.4/Comparable.html) object.
   - Preferably a numeric value like an integer or float.

2. During evolution, evolvables are sorted by your goal's fitness interpretation
   - The default goal type is `:maximize`, see goal types below for other options

3. If a goal value is specified, evolution will stop when it is met

**Goal Types**

- Maximize (higher is better)

```ruby
robots = Robot.new_population(evaluation: :maximize) # Defaults to infinity
robots.evolve_to_goal(100) # Evolve until fitness reaches 100+

# Same as above
Robot.new_population(evaluation: { maximize: 100 }).evolve_to_goal
```

- Minimize (lower is better)

```ruby
errors = ErrorModel.new_population(evaluation: :minimize) # Defaults to -infinity
errors.evolve_to_goal(0.01)  # Evolve until error rate reaches 0.01 or less

# Same as above
ErrorModel.new_population(evaluation: { minimize: 0.01 }).evolve_to_goal
```

- Equalize (closer to target is better)

```ruby
targets = TargetMatcher.new_population(evaluation: :equalize) # Defaults to 0
targets.evolve_to_goal(42)  # Evolve until we match the target value

# Same as above
TargetMatcher.new_population(evaluation: { equalize: 42 }).evolve_to_goal
```


**Custom Goals**

You can create custom goals by subclassing `Evolvable::Goal` and implementing:
- `evaluate(evolvable)`: Return a value that for sorting evolvables
- `met?(evolvable)`: Returns true when the goal value is reached


Example goal implementation that prioritizes evolvables with fitness values within a specific range:

```ruby
class YourRangeGoal < Evolvable::Goal
  def value
    @value ||= 0..100
   end

  def evaluate(evolvable)
    return 1 if value.include?(evolvable.fitness)

    min, max = value.minmax
    -[(min - evolvable.fitness).abs, (max - evolvable.fitness).abs].min
  end

  def met?(evolvable)
    value.include?(evolvable.fitness)
  end
end
```


[Evaluation Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Evaluation)

[Goal Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Goal)

## Evolution

**Evolution** moves a population from one generation to the next.
It runs in three steps: selection, combination, and mutation.
You can swap out any step with your own strategy.

Default pipeline:
1. **Selection** – keep the most fit evolvables
2. **Combination** – create offspring by recombining genes
3. **Mutation** – add random variation to preserve diversity


[Evolution Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Evolution)

## Selection

Selection determines which evolvables will serve as parents for the next
generation. You can control the selection process in several ways:

Set the selection size during population initialization:

```ruby
population = MyEvolvable.new_population(
  selection: { size: 3 }
)
```

Adjust the selection size after initialization:

```ruby
population.selection_size = 4
```

Manually assign the selected evolvables:

```ruby
population.selected_evolvables = [evolvable1, evolvable2]
```

Or evolve a custom selection directly:

```ruby
population.evolve_selected([evolvable1, evolvable2])
```

This flexibility lets you implement custom selection strategies,
overriding or augmenting the built-in behavior.


[Selection Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Selection)

## Combination

Combination is the process of creating new evolvables by mixing the genes
of selected parents. This step drives the creation of the next generation
by recombining traits in novel ways.

You can choose from several built-in combination strategies or implement your own.
By default, Evolvable uses `Evolvable::GeneCombination`, which delegates
gene-level behavior to individual gene classes.

To define custom combination logic for a gene type, implement:

```ruby
YourGeneClass.combine(parent_1_gene, parent_2_gene)
```


[Combination Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Combination)

**Point Crossover**

A classic genetic algorithm strategy that performs single or multi-point crossover
by selecting random positions in the genome and swapping gene segments between parents.

- **Single-point crossover (default):** Swaps all genes after a randomly chosen position.
- **Multi-point crossover:** Alternates segments between multiple randomly chosen points.

Best for:
- Preserving beneficial gene blocks
- Problems where related traits are located near each other

Set your population to use this strategy during initialization with:

```ruby
population = MyEvolvable.new_population(
  combination: Evolvable::PointCrossover.new(points_count: 2)
)
```

Or update an existing population:

```ruby
population.combination = Evolvable::PointCrossover.new(points_count: 3)
```


[PointCrossover Documentation](https://mattruzicka.github.io/evolvable/Evolvable/PointCrossover)

**Uniform Crossover**

Chooses genes independently at each position, selecting randomly from either
parent with equal probability. No segments are preserved—each gene is treated
in isolation.

Best for:
- Problems where gene order doesn't matter
- High genetic diversity and exploration
- Complex interdependencies across traits

Uniform crossover is especially effective when good traits are scattered across the genome.

Set your population to use this strategy during initialization with:

```ruby
population = MyEvolvable.new_population(
  combination: Evolvable::UniformCrossover.new
)
```

Or update an existing population:

```ruby
population.combination = Evolvable::UniformCrossover.new
```


[UniformCrossover Documentation](https://mattruzicka.github.io/evolvable/Evolvable/UniformCrossover)

## Mutation

Mutation introduces genetic variation by randomly replacing genes with new
ones. This helps the population explore new areas of the solution space
and prevents premature convergence on suboptimal solutions.

Mutation is controlled by two key parameters:
- **probability**: Likelihood that an individual will undergo mutation (range: 0.0–1.0)
- **rate**: Fraction of genes to mutate within those individuals (range: 0.0–1.0)

A typical strategy is to start with higher mutation to encourage exploration:

```ruby
population = MyEvolvable.new_population(
  mutation: { probability: 0.4, rate: 0.2 }
)
```

Then later reduce the mutation rate to focus on refinement and convergence:

```ruby
population.mutation_probability = 0.1
population.mutation_rate = 0.05
```


[Mutation Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Mutation)

## Gene Clusters

Gene clusters group related genes into reusable components that can be applied
to multiple evolvable classes. This promotes clean organization, eliminates
naming conflicts, and simplifies gene access.

**Benefits:**
- Reuse gene groups across multiple evolvables
- Prevent name collisions via automatic namespacing
- Treat clusters as structured subcomponents of a genome
- Access all genes in a cluster with a single method call

The `ColorPaletteCluster` below defines a group of genes commonly used for styling themes:

```ruby
class ColorPaletteCluster
  include Evolvable::GeneCluster

  gene :primary, type: 'ColorGene', count: 1
  gene :secondary, type: 'ColorGene', count: 1
  gene :accent, type: 'ColorGene', count: 1
  gene :neutral, type: 'ColorGene', count: 1
end
```

Use the `cluster` macro to apply the cluster to your evolvable class:

```ruby
class Theme
  include Evolvable

  cluster :colors, type: ColorPaletteCluster

  def inspect_colors
    colors.join(", ")
  end
end
```

When a cluster is applied, its genes are automatically namespaced with the cluster name:
- Access the full group: `theme.colors` → returns all genes in the colors cluster
- Access individual genes: `theme.find_gene("colors-primary")`


[GeneCluster Documentation](https://mattruzicka.github.io/evolvable/Evolvable/GeneCluster)

## Community

The `Community` module provides a framework for coordinating multiple evolvable populations
under a unified interface. Each population represents a distinct type of evolvable, and
each key returns a single evolvable instance drawn from its corresponding population.

Communities are ideal for simulations or systems where different components evolve
in parallel but interact as part of a larger whole - such as ecosystems, design systems,
or modular agents. Evolvables from different populations can co-evolve, influencing each other's fitness.

Use the `evolvable_community` macro to declare the set of named populations in the community.
Each population will have a corresponding method (e.g., `fish_1`, `plant`, `shrimp`) that
returns a single evolvable instance. You can evolve all populations together using the
`evolve` method, or per population.

**Key Features**
- Define a community composed of named populations
- Automatically generate accessors for each evolvable instance
- Coordinate evolution across populations through a shared interface
- Evolve all populations in a single call with `evolve(...)`

This `FishTank` example sets up a community with four named populations:

```ruby
class FishTank
  include Evolvable::Community

  evolvable_community fish_1: Fish,
                      fish_2: Fish,
                      plant: AquariumPlant,
                      shrimp: CleanerShrimp

  def describe_tank
    puts "🐟 Fish 1: #{fish_1.name} (#{fish_1.color})"
    puts "🐟 Fish 2: #{fish_2.name} (#{fish_2.color})"
    puts "🌿 Plant: #{plant.name} (#{plant.color})"
    puts "🦐 Shrimp: #{shrimp.name} (#{shrimp.color})"
  end
end
```

Initialize the community, describe the tank, and evolve each population:

```ruby
tank = FishTank.new_community
tank.describe_tank
tank.evolve
```


[Community Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Community)

## Serialization

Evolvable supports saving and restoring the state of both populations
and individual evolvable instances through a built-in `Serializer`.
By default, it uses Ruby's `Marshal` class for fast, portable binary serialization.

Serialization is useful for:
- Saving progress during long-running evolution
- Storing champion solutions for later reuse
- Transferring evolved populations between systems
- Creating checkpoints you can revert to

Both `Population` and individual evolvables expose `dump` and `load` methods
that use the `Serializer` internally.

Save a population to a file:

```ruby
population = YourEvolvable.new_population
population.evolve(count: 100)
File.write("population.marshal", population.dump)
```

Restore and continue evolution:

```ruby
data = File.read("population.marshal")
restored = Evolvable::Population.load(data)
restored.evolve(count: 100)
```

Save an individual evolvable's genome:

```ruby
best = restored.best_evolvable
File.write("champion.marshal", best.dump_genome)
```

Restore genome into a new evolvable:

```ruby
raw = File.read("champion.marshal")
champion = YourEvolvable.new_evolvable
champion.load_genome(raw)
```


[Serializer Documentation](https://mattruzicka.github.io/evolvable/Evolvable/Serializer)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattruzicka/evolvable.