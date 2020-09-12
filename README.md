# Evolvable

A framework for building evolutionary behaviors in Ruby.

[Evolutionary algorithms](https://en.wikipedia.org/wiki/Evolutionary_algorithm) build upon ideas such as natural selection, crossover, and mutation to construct relatively simple solutions to complex problems. This gem has been used to implement evolutionary behaviors for [visual, textual, and auditory experiences](https://projectpag.es/evolvable) as well as a variety of AI agents.

With a straightforward and extensible API, Evolvable aims to make building simple as well as complex evolutionary algorithms fun and relatively easy.

### The Evolvable Abstraction
Population objects are composed of instances that include the `Evolvable` module. Instances are composed of gene objects that include the `Evolvable::Gene` module. Evaluation and evolution objects are used by population objects to evolve your instances. An evaluation object has one goal object and the evolution object is composed of selection, crossover, and mutation objects by default.

All classes exposed by Evolvable are prefixed with `Evolvable::` and can be configured, inherited, removed, and extended. You can also choose between various Evolvable implementations documented below or substitute your own. Don't worry if none of this made sense, this will become clearer as you continue reading.

## Installation

Add `gem 'evolvable'` to your application's Gemfile and run `bundle install` or install it yourself with `gem install evolvable`

## Getting Started

After installing and requiring the "evolvable" Ruby gem:

1. Include the `Evolvable` module in the class for the instances you want to evolve. (See [Configuration](#Configuration)).
2. Implement `.gene_space`, define any gene classes referenced by it, and include the `Evolvable::Gene` module for each. (See [Genes](#Genes)).
3. Implement `#value`. (See [Evaluation](#Evaluation)).
4. Initialize a population and start evolving. (See [Populations](#Populations)).

Visit the [Evolving Strings](https://github.com/mattruzicka/evolvable/wiki/Evolving-Strings) tutorial to see these steps in action. It walks through a simplified implementation of the [evolve string](https://github.com/mattruzicka/evolve_string) command-line program. Here's the [example source code](https://github.com/mattruzicka/evolvable/blob/master/examples/evolvable_string.rb) for the tutorial.

If you’d like to quickly play around with an evolvable string Population object, you can do so by cloning this repo and running the command `bin/console` in this project's directory.

## Usage
- [Configuration](#Configuration)
- [Genes](#Genes)
- [Populations](#Populations)
- [Evaluation](#Evaluation)
- [Evolution](#Evolution)
- [Selection](#Selection)
- [Crossover](#Crossover)
- [Mutation](#Mutation)

## Configuration

You'll need to define a class for the instances you want to evolve and include the `Evolvable` module. Let's say you want to evolve a melody. You might do something like this:

```ruby
class Melody
  include Evolvable

  def self.gene_space
    # Expected
  end

  def value
    # Required
  end
end
```

The `Evolvable` module exposes the following class and instance methods for you.

#### .gene_space

You're expected to override this and return a gene space configuration hash or GeneSpace object.

Here's a sample definition for the melody class defined above. It configures each instance to have 16 note genes and 1 instrument gene.

```ruby
def self.gene_space
  { instrument: { type: 'InstrumentGene', count: 1 },
    notes: { type: 'NoteGene', count: 16 } }
end
```

See the section on [Genes](#genes) for more details.

#### .new_population(keyword_args = {})

Initializes a new population. Example: `population = Melody.new_population(size: 100)`

Accepts the same arguments as `Population.new`

#### .new_instance(population: nil, genes: [], population_index: nil)

Initializes a new instance. Accepts a population object, an array of gene objects, and the instance's population index.

This method is useful for re-initializing instances and populations that have been saved.

_It is not recommended that you override this method_ as it is used by Evolvable internals. If you need to customize how your instances are initialized you can override either of the following two "initialize_instance" methods.

#### .initialize_instance

The default implementation simply delegates to `.new` and is useful for instances with custom initialize methods.

#### #initialize_instance

Runs after Evolvable finishes building your instance. It's useful for stuff like implementing custom gene initialization logic. For example, the Evolvable Strings web demo (coming soon) uses it to read from a "length gene" and add or remove "char genes" accordingly.

#### #population, #population=

The population object being used to evolve this instance.

#### #genes, #genes=

An array of all an instance's genes. You can find specific types of genes with the following two methods.

#### #find_genes(key)

Returns an array of genes that have the given key. Gene keys are defined in the [.gene_space](#gene_space) method. In the Melody example above, the key for the note genes would be `:notes`. The following would return an array of them: `note_genes = melody.find_genes(:notes)`

#### #find_gene(key)

Returns the first gene with the given key. In the Melody example above, the instrument gene has the key `:instrument` so we might write something like: `instrument_gene = melody.find_gene(instrument)`

#### #population_index, #population_index=

Returns an instance's population index - an integer representing the order in which it was initialized in a population. It's the most basic way to distinguish instances in a population.

#### #value

It is required that you implement this method. It is used when evaluating instances before undergoing evolution.

Technically, this method can return any object that implements Ruby's [Comparable](https://ruby-doc.org/core-2.7.1/Comparable.html). See the section on [Evaluation](#Evaluation) for details.

#### Evolvable Hooks

The following class methods can be overridden in order to hook into a population's evolutions. The hooks run for each evolution in the following order:

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

#### The Evolvable::Gene module

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
Here, the "sample space" for the NoteGene class has twelve notes, but each individual object will have only one note. The note is randomly chosen when the "value" method is invoked for the first time.

_It is important that the data for a particular gene never change._ Ruby's or-equals operator `||=` is super useful for memoizing gene attributes like this. It is used above to randomly pick a note only once and return the same note for the lifetime of the object.

A melody instance with multiple note genes might use the `NoteGene#value` method to compose the notes of its melody like so: `melody.find_genes(:note).map(&:value)`. Let's keep going with this example and implement the `InstrumentGene` too:

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

In this way, instances can express behaviors via genes and even orchestrate interactions between them. Genes can also interact with each other during an instance's initialization process via the [#initialize_instance](#initialize_instance-1) method

#### The Evolvable::GeneSpace object

The `Evolvable::GeneSpace` object is responsible for initializing the full set of genes for a particular instance according to the configuration returned by the [.gene_space](#gene_space) method. It is used by the `Evolvable::Population` to initialize new instances.

Technically, any object that responds to a `new_genes` method which returns an array of genes for a particular instance can function as a GeneSpace object. Custom implementations will be used if returned by the `.gene_space` method.


## Populations

The `Evolvable::Population` object is responsible for generating and evolving instances. It orchestrates all the other Evolvable objects in order to do so.


#### .new

Accepts the following keyword arguments:
**evolvable_class** - Required. Implicitly specified when using EvolvableClass.new_population.
**id**, **name** - Default to `nil`. Not used by Evolvable, but convenient when working with multiple populations.
**size** - Defaults to `40`. Specifies the number of instances in the population.
**evolutions_count** - Defaults to `0`. Useful when re-initializing a saved population with instances.
**gene_space** - Defaults to `evolvable_class.new_gene_space` which uses the [.gene_space](#gene_space) method
**evolution** - Defaults to `Evolution.new`. (See [evolution](#evolution))
**evaluation** - Defaults to `Evaluation.new`, with a goal of maximizing towards Float::INFINITY (See [evaluation](#evaluation))
**instances** - Defaults to initializing a `size` number of `evolvable_class` instances using the `gene_space` object. Any given instances are assigned, but if given less than `size`, more will be initialized.

#### #evolve

Accepts the following keyword arguments:
**count** The number of evolutions to run. Expects a positive integer and Defaults to Float::INFINITY. Will continue running until reached unless a `goal_value` is specified
**goal_value** Assigns the goal object's value. (See [evaluation](#evaluation)). Will continue running until an instance's value reaches it.

#### #best_instance
Returns an instance with the value that is closest to the goal value.

#### #met_goal?
Returns true if any instance's value matches the goal value, otherwise false.

#### #new_instance
Used to initialize instances for this population. Not that this method will not actually add the initialized instance to its array of instances.

Accepts the following keyword arguments:
**genes** - An array of initialized gene objects. Defaults to `[]`
**population_index** Defaults to `nil` and expects an integer. See (Evolvable#population_index)[https://github.com/mattruzicka/evolvable#population_index-population_index]


#### selection, selection=
The [selection](#selection) object.

#### crossover, crossover=
The [crossover](#crossover) object.

#### mutation, mutation=
The [mutation](#mutation) object.

#### goal, goal=
The [evaluation](#evaluation)'s goal object.

## Evaluation

In order for selection to be effective in the context of progressive evolution, there needs to be some way of comparing various instances with each other. In traditional genetic algorithms, this is referred to as the "fitness function". Evolvable uses the `Evolvable::Evaluation` object which expects instances to define a [#value](https://github.com/mattruzicka/evolvable#value) method in order to evaluate them relative to each other against a customizable goal and value.

A goal object has a value which can be most easily assigned via an argument to `Evolvable::Population#evolve` like so `population.evolve(goal_value: 1000)`. Evolvable provides the following goal object implementations and goal value defaults.

#### The Evolvable::Goal::Maximize object

Prioritizes instances with greater values. This is the default.

The default goal value is `Float::INFINITY`, but it can be reassigned as anything that implements the Ruby [Comparable](https://ruby-doc.org/core-2.7.1/Comparable.html) module.

#### The Evolvable::Goal::Minimize object

Prioritizes instances with lesser values.

The default goal value is `-Float::INFINITY`, but it can be reassigned as anything that implements the Ruby [Comparable](https://ruby-doc.org/core-2.7.1/Comparable.html) module.

#### The Evolvable::Goal::Equalize object

Prioritizes instances which equal the goal value.

The default goal value is `0`, but it can be reassigned as anything that implements the Ruby [Comparable](https://ruby-doc.org/core-2.7.1/Comparable.html) module.

#### Custom Goal Objects

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

The goal for a population can be specified via assignment - `population.goal = Evolvable::Goal::Equalize.new` - or by passing an evaluation object when [initializing a population](#populations)


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

TODO, The Evolvable::Evolution object

## Selection

TODO, The Evolvable::Selection object

## Crossover

TODO

#### The Evolvable::GeneCrossover object

Enables genes to define their own crossover behavior. The default implementation mirrors the behavior of `Evolvable::UniformCrossover`

#### The Evolvable::UniformCrossover object

Randomly chooses a gene from one of the parents for each gene position.

#### The Evolvable::PointCrossover object

Supports single and mutli point crossover. The default is single point crossover with a `points_count` of 1 which can be changed on an existing population (`population.crossover.points_count = 5`) or during initialization (`Evolvable::PointCrossover.new(5)`)

## Mutation

TODO, The Evolvable::Mutation object
