# Evolvable

A framework for building evolutionary behaviors using object-oriented Ruby.

[Evolutionary algorithms](https://en.wikipedia.org/wiki/Evolutionary_algorithm) build upon ideas such as natural selection, crossover, and mutation to construct relatively simple solutions to complex problems. This gem has been used to implement evolutionary behaviors for [visual, textual, and auditory experiences](https://projectpag.es/evolvable) as well as a variety of AI agents.

With its straightforward and extensible API, Evolvable aims to make building simple and complex evolutionary algorithms fun and relatively easy.

## Demos
- [Evolvable Strings](https://evolvable.dev/strings)

## Installation
Add `gem 'evolvable'` to your application's Gemfile and run `bundle install` or install it yourself with `gem install evolvable`

## Getting Started

After installing and requiring the "evolvable" Ruby gem:

1. Include the `Evolvable` module in the class for the instances you want to evolve. (See [Instances](#Instances)).
2. Implement a `.gene_space` class method, define any gene classes referenced by it, and include the `Evolvable::Gene` module for each. (See [Genes](#Genes)).
3. Implement a `#value` instance method on the evolvable class you defined in step 1. (See [Evaluation](#Evaluation)).
4. Initialize a population and start evolving. (See [Population](#Population)).

Visit [The Evolvable String Tutorial](https://gist.github.com/mattruzicka/3cd4c73b6c5d27f05d2e09af7fff8780) to see these steps in action. It walks through a simplified implementation of the "evolvable strings" demo above. You can also view [the tutorial’s source code](#).

If you’d like to skip to playing around with an evolvable string Population object, you can do so  by cloning this repo and running the command`bin/console` in the evolvable directory.

To see a more interesting, fun, and open-source version of evolvable string, check out this [evolve string](https://github.com/mattruzicka/evolve_string) command line program.

## Usage
- [Instances](#Instances)
- [Genes](#Genes)
- [Evaluation](#Evaluation)
- [Populations](#Populations)
- [Evolution](#Evolution)
- [Selection](#Selection)
- [Crossover](#Crossover)
- [Mutation](#Mutation)

## Instances

After deciding what you want to evolve, you'll want to define your class and include the `Evolvable` module. Your class could be for almost any kind of instance. Let's say you want to evolve a melody. You might do something like this:

```ruby
class Melody
  include Evolvable

  def self.gene_space
    # Expected, see section on "Genes"
  end

  def value
    # Required, see section on "Evaluation"
  end
end
```

#### .gene_space
You're expected to override this method and return a gene space configuration hash or GeneSpace object.

As an example, here's a definition for the melody class above. Each instace will have 16 note genes that represent a single note value and 1 instrument gene.
```ruby
def self.gene_space
  { instrument: { type: 'InstrumentGene', count: 1 },
    notes: { type: 'NoteGene', count: 16 } } }
end
```

See the section on [Genes](#genes) for more details.

#### .new_population(keyword_args = {})
Initializes a new population. Example: `population = Melody.new_population(size: 100)`

Accepts the same arguments as Population.new [documented below](#populations)

#### .new_instance(population: nil, genes: [], population_index: nil)
Initializes a new instance. Accepts a population object, a genes array, and a population_index.

_It is not recommended that you override this method_ as it is used by Evolvable internals. If you need to customize how your instances are initialized you can override either of following two "initialize_instance" methods.

This method is useful for re-initializing instances and populations that have been persisted.

#### .initialize_instance
The default implementation simply delegates to `.new` and is useful for instances with custom initialize methods.

#### #initalize_instance
Runs after Evolvable is finished building your instance. It's useful for stuff like implementing custom gene initialization logic. For example, the [Evolvable Strings demo](https://evolvable.dev/strings) uses it to read from a "length gene" and add or remove "char genes" accordingly.

#### #population, #population=
The population object being used to evolve this instance.

#### #genes, #genes=
An array of all this instance's genes. You can find specific types of genes with the following two methods.

#### #find_genes(key)

Returns an array of genes with a key that matches the given key. Gene keys are defined by the [.gene_space](###.gene_space) method. In the Melody example above, the key for the note genes would be `:notes` and this method would return an array of them. Example: `note_genes = melody.find_genes(:notes)`

#### #find_gene(key)
Returns the first gene with the given key. In the Melody example above, a instrument gene will the key `:instrument`. We might write something like `instrument_gene = melody.find_gene(instrument)`

#### #population_index, #population_index=
Returns the instance's integer index in the population. The most basic way to distinguish instances in a population.

#### #value
You must implement this method.

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
    instrument_gene = find_gene(:instrument)
    note_genes = melody.find_genes(:notes)
    instrument_gene.play(note_genes)
  end
end
```


## Genes
Evolvable::Gene
Evolvable::GeneSpace

TODO

## Evaluation
Evolvable::Evaluation

TODO

### Evaluation Goal
Evolvable::Goal::Maximize
Evolvable::Goal::Minimize
Evolvable::Goal::Equalize

## Populations
Evolvable::Population

TODO

## Evolution
Evolvable::Evolution

TODO

## Selection
Evolvable::Selection

TODO

## Crossover
Evolvable::GeneCrossover
Evolvable::UniformCrossover
Evolvable::PointCrossover

TODO

## Mutation
Evolvable::Mutation

TODO
