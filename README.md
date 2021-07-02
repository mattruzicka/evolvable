# Evolvable
[![Gem Version](https://badge.fury.io/rb/evolvable.svg)](https://badge.fury.io/rb/evolvable) [![Maintainability](https://api.codeclimate.com/v1/badges/7faf84a6d467718b33c0/maintainability)](https://codeclimate.com/github/mattruzicka/evolvable/maintainability)

A framework for building evolutionary behaviors in Ruby.

[Evolutionary algorithms](https://en.wikipedia.org/wiki/Evolutionary_algorithm) build upon ideas such as natural selection, crossover, and mutation to construct relatively simple solutions to complex problems. This gem has been used to implement evolutionary behaviors for [visual, textual, and auditory experiences](https://projectpag.es/evolvable) as well as a variety of AI agents.

With a straightforward and extensible API, Evolvable aims to make building simple as well as complex evolutionary algorithms fun and relatively easy.

### The Evolvable Abstraction
Population objects are composed of instances that include the `Evolvable` module. Instances are composed of gene objects that include the `Evolvable::Gene` module. Evaluation and evolution objects are used by population objects to evolve your instances. An evaluation object has one goal object and the evolution object is composed of selection, crossover, and mutation objects by default. All classes exposed by Evolvable are prefixed with `Evolvable::` and can be configured, inherited, removed, and extended.

## Installation

Add `gem 'evolvable'` to your application's Gemfile and run `bundle install` or install it yourself with `gem install evolvable`

## Getting Started

After installing and requiring the "evolvable" Ruby gem:

1. Include the `Evolvable` module in the class for the instances you want to evolve. (See [Configuration](#Configuration)).
2. Implement `.search_space`, define any gene classes referenced by it, and include the `Evolvable::Gene` module for each. (See [Genes](#Genes)).
3. Implement `#value`. (See [Evaluation](#evaluation-1)).
4. Initialize a population and start evolving. (See [Populations](#Populations)).

Visit the [Evolving Strings](https://github.com/mattruzicka/evolvable/wiki/Evolving-Strings) tutorial to see these steps in action. It walks through a simplified implementation of the [evolve string](https://github.com/mattruzicka/evolve_string) command-line program. Here's the [example source code](https://github.com/mattruzicka/evolvable/blob/master/examples/evolvable_string.rb) for the tutorial.

If you’d like to quickly play around with an evolvable string Population object, you can do so by cloning this repo and running the command `bin/console` in this project's directory.

## Usage
- [Configuration](#Configuration)
- [Genes](#Genes)
- [Populations](#Populations)
- [Evaluation](#evaluation-1)
- [Evolution](#evolution-1)
- [Selection](#selection-1)
- [Crossover](#Crossover)
- [Mutation](#mutation-1)

## Configuration

You'll need to define a class for the instances you want to evolve and include the `Evolvable` module. Let's say you want to evolve a melody. You might do something like this:

```ruby
class Melody
  include Evolvable

  def self.search_space
    { instrument: { type: 'InstrumentGene', count: 1 },
      notes: { type: 'NoteGene', count: 16 } }
  end

  def value
    average_rating # ...
  end
end
```

The `Evolvable` module expects the [".search_space" class method](#evolvableclasssearch_space) and requires the ["#value" instance method](#evolvableclassvalue) to be defined as documented below. Other methods exposed by `Evolvable` have also been documented below.

### EvolvableClass.search_space

You're expected to override this and return a gene space configuration hash or SearchSpace object. It defines the mapping for a hyperdimensional "gene space" so to speak. The above sample definition for the melody class configures each instance to have 16 note genes and 1 instrument gene.

See the section on [Genes](#genes) for more details.

### EvolvableClass.new_population(keyword_args = {})

Initializes a new population. Example: `population = Melody.new_population(size: 100)`

Accepts the same arguments as [Population.new](#evolvablepopulationnew)

### EvolvableClass.new_instance(population: nil, genes: [], population_index: nil)

Initializes a new instance. Accepts a population object, an array of gene objects, and the instance's population index. This method is useful for re-initializing instances and populations that have been saved.

_It is not recommended that you override this method_ as it is used by Evolvable internals. If you need to customize how your instances are initialized you can override either of the following two "initialize_instance" methods.

### EvolvableClass.initialize_instance

The default implementation simply delegates to `.new` and is useful for instances with custom initialize methods.

### EvolvableClass#initialize_instance

Runs after Evolvable finishes building your instance. It's useful for stuff like implementing custom gene initialization logic. For example, the Evolvable Strings web demo (coming soon) uses it to read from a "length gene" and add or remove "char genes" accordingly.

### EvolvableClass#population, #population=

The population object being used to evolve this instance.

### EvolvableClass#genes, #genes=

An array of all an instance's genes. You can find specific types of genes with the following two methods.

### EvolvableClass#find_genes(key)

Returns an array of genes that have the given key. Gene keys are defined in the [EvolvableClass.search_space](#evolvableclasssearch_space) method. In the Melody example above, the key for the note genes would be `:notes`. The following would return an array of them: `note_genes = melody.find_genes(:notes)`

### EvolvableClass#find_gene(key)

Returns the first gene with the given key. In the Melody example above, the instrument gene has the key `:instrument` so we might write something like: `instrument_gene = melody.find_gene(instrument)`

### EvolvableClass#population_index, #population_index=

Returns an instance's population index - an integer representing the order in which it was initialized in a population. It's the most basic way to distinguish instances in a population.

### EvolvableClass#value

You must implement this method. It is used when evaluating instances before undergoing evolution. The above melody example imagines that the melodies have ratings and uses them as the basis for evaluation and selection.

Technically, this method can return any object that implements Ruby's [Comparable](https://ruby-doc.org/core-2.7.1/Comparable.html). See the section on [Evaluation](#evaluation-1) for details.

### Evolvable Hooks

The following class method hooks can be overridden. The hooks run for each evolution in the following order:

**.before_evaluation(population)**

**.before_evolution(population)**

**.after_evolution(population)**

To use our Melody example from above, you could override the `.before_evolution` method to play the best melody from each generation with something like this:

```ruby
class Melody
  def self.before_evolution(population)
    best_melody = population.best_instance
    best_melody.play
  end

  def play
    note_genes = melody.find_genes(:notes)
    note_values = note_genes.map(&:value)
    find_gene(:instrument).play(note_values)
  end
end
```

## Genes

Instances rely on gene objects to compose behaviors. In other words, a gene can be thought of as an object that in some way affects the behavior of an instance. They are used to encapsulate a "sample space" and return a sample outcome when accessed.

### The Evolvable::Gene module

Gene objects must include the `Evolvable::Gene` module which enables them to undergo evolutionary operations such as crossover and mutation.

To continue with the melody example, we might encode a NoteGene like so:

```ruby
class NoteGene
  include Evolvable::Gene

  NOTES = ['C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B']

  def value
    @value ||= NOTES.sample
  end
end
```
Here, the "sample space" for the NoteGene class has twelve notes, but each object will have only one note which is randomly chosen when the "value" method is invoked for the first time. _It is important that the data for a particular gene never change._ Ruby's or-equals operator `||=` is super useful for memoizing gene attributes. It is used above to randomly pick a note only once and return the same note for the lifetime of the object.

A melody instance with multiple note genes might use the `NoteGene#value` method to compose the notes of its melody like so: `melody.find_genes(:note).map(&:value)`. Let's keep humming with the melody example and implement the `InstrumentGene` too:

```ruby
class InstrumentGene
  include Evolvable::Gene

  def instrument_class
    @instrument_class ||= [Guitar, Synth, Trumpet].sample
  end

  def volume
    @volume ||= rand(1..100)
  end

  def play(notes)
    instrument_class.play(notes: notes, volume: volume)
  end
end
```

You can model your sample space however you like. Ruby's [Array](https://ruby-doc.org/core-2.7.1/Array.html), [Hash](https://ruby-doc.org/core-2.7.1/Hash.html), [Range](https://ruby-doc.org/core-2.7.1/Range.html), and [Random](https://ruby-doc.org/core-2.7.1/Random.html) classes may be useful. This InstrumentGene implementation has 300 possible outcomes (3 instruments * 100 volumes) and uses Ruby's Array, Range, and Random classes.

Now that its genes are implemented, a melody instance can use them:

```ruby
class Melody
  include Evolvable

  # ...

  def play
    note_genes = melody.find_genes(:notes)
    note_values = note_genes.map(&:value)
    find_gene(:instrument).play(note_values)
  end
end
```

In this way, instances can express behaviors via genes and even orchestrate interactions between them. Genes can also interact with each other during an instance's initialization process via the [EvolvableClass#initialize_instance](#evolvableclassinitialize_instance-1) method

### The Evolvable::SearchSpace object

The `Evolvable::SearchSpace` object is responsible for initializing the full set of genes for a particular instance according to the configuration returned by the [EvolvableClass.search_space](#evolvableclasssearch_space) method. It is used by the `Evolvable::Population` to initialize new instances.

## Populations

The `Evolvable::Population` object is responsible for generating and evolving instances. It orchestrates all the other Evolvable objects to do so.

### Evolvable::Population.new

Initializes an Evolvable::Population.

Keyword arguments:

#### evolvable_class
Required. Implicitly specified when using EvolvableClass.new_population.
#### id, name
Both default to `nil`. Not used by Evolvable, but convenient when working with multiple populations.
#### size
Defaults to `40`. Specifies the number of instances in the population.
#### evolutions_count
Defaults to `0`. Useful when re-initializing a saved population with instances.
#### search_space
Defaults to `evolvable_class.new_search_space` which uses the [EvolvableClass.search_space](#evolvableclasssearch_space) method
#### evolution
Defaults to `Evolvable::Evolution.new`. See [evolution](#evolution-1)
#### evaluation
Defaults to `Evolvable::Evaluation.new`, with a goal of maximizing towards Float::INFINITY. See [evaluation](#evaluation-1)
#### instances
Defaults to initializing a `size` number of `evolvable_class` instances using the `search_space` object. Any given instances are assigned, but if given less than `size`, more will be initialized.

### Evolvable::Population#evolve

Keyword arguments:

#### count
The number of evolutions to run. Expects a positive integer and Defaults to Float::INFINITY and will therefore run indefinitely unless a `goal_value` is specified.
#### goal_value
Assigns the goal object's value. Will continue running until any instance's value reaches it. See [evaluation](#evaluation-1)

### Evolvable::Population#best_instance
Returns an instance with the value that is nearest to the goal value.

### Evolvable::Population#met_goal?
Returns true if any instance's value matches the goal value, otherwise false.

### Evolvable::Population#new_instance
Initializes an instance for the population. Note that this method does not add the new instance to its array of instances.

Keyword arguments:

#### genes
An array of initialized gene objects. Defaults to `[]`
#### population_index
Defaults to `nil` and expects an integer. See (EvolvableClass#population_index)[#evolvableclasspopulation_index-population_index]


### Population#selection, #selection=
The [selection](#selection-1) object.

### Population#crossover, #crossover=
The [crossover](#crossover) object.

### Population#mutation, #mutation=
The [mutation](#mutation-1) object.

### Population#goal, #goal=
The [evaluation](#evaluation-1)'s goal object.

## Evaluation

For selection to be effective in the context of progressive evolution, there needs to be some way of comparing various instances with each other. In traditional genetic algorithms, this is referred to as the "fitness function". The `Evolvable::Evaluation` object expects instances to define a [EvolvableClass#value](#evolvableclassvalue) method that it uses to evaluate them relative to each other and against a definable goal.

A goal object has a value that can be most easily assigned via an argument to `Evolvable::Population#evolve` like this: `population.evolve(goal_value: 1000)`. Evolvable provides the following goal object implementations and goal value defaults.

### The Evolvable::Goal::Maximize object

Prioritizes instances with greater values. This is the default.

The default goal value is `Float::INFINITY`, but it can be reassigned as anything that implements the Ruby [Comparable](https://ruby-doc.org/core-2.7.1/Comparable.html) module.

### The Evolvable::Goal::Minimize object

Prioritizes instances with lesser values.

The default goal value is `-Float::INFINITY`, but it can be reassigned as anything that implements the Ruby [Comparable](https://ruby-doc.org/core-2.7.1/Comparable.html) module.

### The Evolvable::Goal::Equalize object

Prioritizes instances that equal the goal value.

The default goal value is `0`, but it can be reassigned as anything that implements the Ruby [Comparable](https://ruby-doc.org/core-2.7.1/Comparable.html) module.

### Custom Goal Objects

You can implement custom goal object like so:

```ruby
class CustomGoal
  include Evolvable::Goal

  def evaluate(instance)
    # Required by Evolvable::Evaluation in order to sort instances in preparation for selection.
  end

  def met?(instance)
    # Used by Evolvable::Population#evolve to stop evolving when the goal value has been reached.
  end
end
```

The goal for a population can be specified via assignment - `population.goal = Evolvable::Goal::Equalize.new` - or by passing an evaluation object when [initializing a population](#evolvablepopulationnew).

You can intialize the `Evolvable::Evaluation` object with any goal object like this:

```ruby
goal_object = SomeGoal.new(value: 100)
Evolvable::Evaluation.new(goal_object)
```

or more succinctly like this:

```ruby
Evolvable::Evaluation.new(:maximize) # Uses default goal value of Float::INFINITY
Evolvable::Evaluation.new(maximize: 50) # Sets goal value to 50
Evolvable::Evaluation.new(:minimize) # Uses default goal value of -Float::INFINITY
Evolvable::Evaluation.new(minimize: 100) # Sets goal value to 100
Evolvable::Evaluation.new(:equalize) # Uses default goal value of 0
Evolvable::Evaluation.new(equalize: 1000) # Sets goal value to 1000

```

## Evolution

After a population's instances are evaluated, they undergo evolution. The default `Evolvable::Evolution` object is composed of selection, crossover, and mutation objects and applies them as operations to the population in that order.

Populations can be assigned with custom evolution objects. The only necessary dependency for evolution objects is that they implement the `#call` method which accepts a population as the first argument. Population objects also expect evolution objects to define a getter and setter for selection, crossover, and mutation, but these methods are simply for ease-of-use and not necessary.

### Evolvable::Evolution.new

Initializes a new evolution object.

Keyword arguments:

#### selection
The default is `Selection.new`
#### crossover
The default is `GeneCrossover.new`
#### mutation
The default is `Mutation.new`

## Selection

The selection process assumes that the population's instances have already been sorted by the `Evaluation` object. It leaves only a select number of instances in a given population's instances array.

Custom selection objects must implement the `#call` method which accepts the population as the first object.

### Evolvable::Selection.new

Initializes a new selection object.

Keyword arguments:

#### size
The number of instances to select from each generation from which to perform crossover and generate or "breed" the next generation. The number of parents The default is 2.

## Crossover

Generates new instances by combining the genes of selected instances. You can think of it as a mixing of parent genes from one generation to produce a next generation.

Custom crossover objects must implement the `#call` method which accepts the population as the first object.

### The Evolvable::GeneCrossover object

Enables gene types to define crossover behaviors. Each gene class can implement a unique behavior for crossover by overriding the following default implementation which mirrors the behavior of `Evolvable::UniformCrossover`

```ruby
def self.crossover(gene_a, gene_b)
  [gene_a, gene_b].sample
end
```

### The Evolvable::UniformCrossover object

Randomly chooses a gene from one of the parents for each gene position.

### The Evolvable::PointCrossover object

Supports single and multi-point crossover. The default is single-point crossover via a `points_count` of 1 which can be changed on an existing population (`population.crossover.points_count = 5`) or during initialization (`Evolvable::PointCrossover.new(5)`)

## Mutation

Mutation serves the role of increasing genetic variation, especially when a population's instances are small in number and mostly homogeneous. When an instance undergoes a mutation, it means that one of its existing genes is replaced with a newly initialized gene. Using the language from the [section on genes](genes), a gene mutation invokes a new outcome from the gene's sample space.

### Evolvable::Mutation.new

Initializes a new mutation object.

Keyword arguments:

#### probability
The probability that a particular instance undergoes a mutation. By default, the probability is 0.03 which translates to 3%. If initialized with a `rate`, the probability will be 1 which means all genes _can_ undergo mutation, but actual gene mutations will be subject to the given mutation rate.
#### rate
the rate at which individual genes mutate. The default rate is 0 which, when combined with a non-zero `probability` (the default), means that one gene for each instance that undergoes mutation will change. If a rate is given, but no `probability` is given, then the `probability` will bet set to 1 which always defers to the mutation rate.

To summarize, the `probability` represents the chance of mutation on the instance level and the `rate` represents the chance on the gene level. The `probability` and `rate` can be any number from 0 to 1. When the `probability` is 0, no mutation will ever happen. When the `probability` is not 0 but the rate is 0, then any instance that undergoes mutation will only receive one mutant gene. If the rate is not 0, then if an instance has been chosen to undergo mutation, each of its genes will mutate with a probability as defined by the `rate`.

Example Initializations:

```ruby
Evolvable::Mutation.new # Approximately 3% of instances will receive one mutant gene
Evolvable::Mutation.new(probability: 0.5) # Approximately 50% of instances will receive one mutant gene
Evolvable::Mutation.new(rate: 0.03) # Approximately  3% of all genes in the population will mutate.
Evolvable::Mutation.new(probability: 0.3, rate: 0.03) # Approximately 30% of instances will have approximately 3% of their genes mutated.
```

Custom mutation objects must implement the `#call` method which accepts the population as the first object.
