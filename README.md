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

Visit the [Evolvable Strings Tutorial](https://github.com/mattruzicka/evolvable/wiki/Evolvable-Strings-Tutorial) to see these steps in action. It walks through a simplified implementation of the [evolve string](https://github.com/mattruzicka/evolve_string) command-line program. Here's the [example source code](https://github.com/mattruzicka/evolvable/blob/master/examples/evolvable_string.rb) for the tutorial.

If you’d like to quickly play around with an evolvable string Population object, you can do so by cloning this repo and running the command `bin/console` in this project's directory.

## Usage
- [Configuration](#Configuration)
- [Genes](#Genes)
- [Evaluation](#Evaluation)
- [Populations](#Populations)
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

Returns an array of genes that have the given key. Gene keys are defined in the [.gene_space](####.gene_space) method. In the Melody example above, the key for the note genes would be `:notes`. The following would return an array of them: `note_genes = melody.find_genes(:notes)`

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

TODO

## Evaluation

TODO

#### The Evolvable::Evaluation object

TODO

#### The Evolvable::Goal::Maximize object

TODO

#### The Evolvable::Goal::Minimize object

TODO

#### The Evolvable::Goal::Equalize object

TODO

## Populations

TODO

#### The Evolvable::Population object

TODO

## Evolution

TODO

#### The Evolvable::Evolution object

TODO

## Selection

TODO

#### The Evolvable::Selection object

TODO

## Crossover

TODO

#### The Evolvable::GeneCrossover object

TODO

#### The Evolvable::UniformCrossover object

TODO

#### The Evolvable::PointCrossover object

TODO

## Mutation

TODO

#### The Evolvable::Mutation object

TODO
