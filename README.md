# Evolvable 🦎

[![Gem Version](https://badge.fury.io/rb/evolvable.svg)](https://badge.fury.io/rb/evolvable) [![Maintainability](https://api.codeclimate.com/v1/badges/7faf84a6d467718b33c0/maintainability)](https://codeclimate.com/github/mattruzicka/evolvable/maintainability)

An evolutionary framework for writing programs that use operations such as selection, crossover, and mutation. Explore ideas generatively in any domain, discover novel solutions to complex problems, and build intuitions about intelligence, complexity, and the natural world.

Subscribe to the [Evolvable Newsletter](https://www.evolvable.site/newsletter) to slowly learn more, or keep reading this contextualization of the [full documentation](https://rubydoc.info/github/mattruzicka/evolvable).


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
* [Search Space](#search-space)


## Installation

Add [gem "evolvable"](https://rubygems.org/gems/evolvable) to your Gemfile and run `bundle install` or install it yourself with: `gem install evolvable`

## Getting Started

The `Evolvable` module makes it possible to implement evolutionary behaviors for
any class by defining a `.search_space` class method and `#value` instance method.
Then to evolve instances, initialize a population with `.new_population` and invoke
the `#evolve` method on the resulting population object.

### Implementation Steps

1. [Include the `Evolvable` module in the class you want to evolve.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable)
2. [Define `.search_space` and any gene classes that you reference.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/SearchSpace)
3. [Define `#value`.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Evaluation)
4. [Initialize a population with `.new_population` and use `#evolve`.](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Population)


To demonstrate these steps, we'll look at the [Hello World](#) example program.

### Hello World

Let's build the evolvable hello world program using the above steps. It'll evolve a population of arbitrary strings to be more like a given target string. After installing this gem, run `evolvable hello` at the command line to see it in action.

Below is example output from evolving a population of randomly initialized string objects to match "Hello World!", then "Hello Evolvable World".

```
❯ Enter a string to evolve: Hello World!

pp`W^jXG'_N`%              Generation 0
H-OQXZ\a~{H*               Generation 1 ...
HRv9X WorlNi               Generation 50 ...
HRl6W World#               Generation 100 ...
Hello World!               Generation 165

❯ Enter a string to evolve: Hello Evolvable World

Helgo World!b+=1}3         Generation 165
Helgo Worlv!}:c(SoV        Generation 166
Helgo WorlvsC`X(Joqs       Generation 167
Helgo WorlvsC`X(So1RE      Generation 168 ...
Hello Evolv#"l{ Wor*5      Generation 300 ...
Hello Evolvable World      Generation 388
```

### Step 1

Let's begin by defining a `HelloWorld` class and have it **include the `Evolvable` module**.

```ruby
class HelloWorld
  include Evolvable
end
```

### Step 2

Now we can **define the `.search_space`** class method with the types of [genes](#genes) that we want our our evolvable "hello world" instances to be able to have. We'll use `CharGene` instances to represent single characters within strings. So an instance with the string value of "Hello" would be composed of five `CharGene` instances.

```ruby
class HelloWorld
  include Evolvable

  def self.search_space
    ["CharGene", 1..40]
  end
end
```

The [Search Space](#search-space) can be defined in a variety of ways. The above is shorthand that's useful for when there's only one type of gene. This method can also return an array of arrays or hash.

The `1..40` specifies the range of possible genes for a particular HelloWorld instance. Evolvable translates this range or integer value into a `Evolvable::CountGene` object.

By specifying a range, an `Evolvable::CountGene` instance can change the number of genes that are present in an evovlable instance. Count genes undergo evolutionary operations like any other gene. Their effects can be seen in the letter changes from Generation 165 to 168 in the above example output.

To finish step 2, we'll **define the gene class** that we referenced in the above `.search_space` method. Gene classes should include the `Evolvable::Gene` module.

```ruby
class CharGene
  include Evolvable::Gene

  def self.chars
    @chars ||= 32.upto(126).map(&:chr)
  end

  def to_s
    @to_s ||= self.class.chars.sample
  end
end
```

It's important that, once accessed, the data for a particular gene never change. When the `#to_s` method first runs, Ruby's `||=` operator memoizes the result of randomly picking a char, enabling this method to sample a char only once per gene.

After defining the search space, we can now initialize `HelloWorld` instances with random genes, but to actually evolve them, we need to **define the `#value` instance method**. It provides the basis for comparing different evolvable instances.

### Step 3

In the next step, we'll set the goal value to 0, so that evolution favors evolvable HelloWorld instances with `#value` methods that return numbers closer to 0. That means we want instances that more closely match their targets to return scores nearer to 0. As an example, if our target is "hello world", an instance that returns "jello world" would have a value of 1 and "hello world" would have a value of 0.

For a working implementation, see the `#value` method in [examples/hello_world.rb](https://github.com/mattruzicka/evolvable/blob/main/examples/hello_world.rb)

### Step 4

Now it's time to **initialize a population with `.new_population`**. By default, evolvable populations seek to maximize numeric values. In this program, we always know the best possible value, so setting the goal to a concrete number makes sense. This is done by passing the evaluation params with equalize set to 0.

We'll also specify the number of instances in a population using the population's `size` parameter and change the mutation porbability from 0.03 (3%) to 0.6 (60%).

Experimentation has suggested that a large mutation probability tends to decrease the time it takes to evolve matches with short strings and has the opposite effect for long strings. This is demonstrated in the example output above by how many generations it took to go from "Hello World!" to "Hello Evolvable World". As an optimization, we could dynamically change the mutation probability using a population hook detailed below, but doing so will be left as an exercise for the reader. [Pull requests are welcome.](#contributing)

```ruby
population = HelloWorld.new_population(size: 100,
                                       evaluation: { equalize: 0 },
                                       mutation: { probability: 0.6 }
```


At this point, everything should work when we run `population.evolve`, but it'll look like nothing is happening. The next section will allow us to gain instight by hooking into the evolutionary process.

### Evolvable Population Hooks

The following class methods can be implemented on your Evolvable class, e.g. HelloWorld, to hook into the Population#evolve lifecycle. This is useful for logging evolutionary progress, optimizing parameters, and creating interactions with and between evolvable instances.

1. `.before_evaluation(population)` - Runs before evaluation.

2. `.before_evolution(population)`- Runs after evaluation and before evolution.

3. `.after_evolution(population)` - Runs after evolution.


Let's define `.before_evolution` to print the best value for each generation. We'll also define `HelloWorld#to_s`, which implicitly delegates to `CharGene#to_s` during the string interpolation that happens.

```ruby
class HelloWorld
  include Evolvable

  def self.before_evolution(population)
    best_evolvable = population.best_evolvable
    evolutions_count = population.evolutions_count
    puts "#{best_evolvable} - Generation #{evolutions_count}"
  end

  # ...

  def to_s
    @to_s ||= genes.join
  end

  # ...
end
```

Finally we can **evolve the population with the `Evolvable::Population#evolve` instance method**.

```ruby
population.evolve
```

**You now know the fundamental steps to building evolvable programs of endless complexity in any domain!** 🐸 The exact implementation for the command line demo can be found in [exe/hello](https://github.com/mattruzicka/evolvable/blob/main/exe/hello) and [examples/hello_world.rb](https://github.com/mattruzicka/evolvable/blob/main/examples/hello_world.rb).

## Concepts

[Populations](#populations) are composed of evolvables which are composed of genes. Evolvables orchestrate behaviors by delegating to gene objects. Collections of genes are organized into genomes and constitute the [search space](#search-space). [Evaluation](#evaluation) and [evolution](#evolution) objects are used to evolve populations. By default, evolution is composed of [selection](#selection), [combination](#combination), and [mutation](#mutation).

The following concept map depicts how genes flow through populations.

![Concept Map](https://github.com/mattruzicka/evolvable/raw/main/examples/images/diagram.png)

Evolvable is designed with extensibility in mind. Evolvable objects such as [evaluation](#evaluation), [evolution](#evolution), [selection](#selection), [combination](#combination), and [mutation](#mutation) can be extended and swapped, potentially in ways that alter the above graph.

## Genes
For evolution to be effective, an evolvable's genes must be able to influence
its behavior. Evolvables are composed of genes that can be used to run simple
functions or orchestrate complex interactions. The level of abstraction is up
to you.

Defining gene classes requires encapsulating some "sample space" and returning
a sample outcome when a gene attribute is accessed. For evolution to proceed
in a non-random way, the same sample outcome should be returned every time
a particular gene is accessed with a particular set of parameters.
Memoization is a useful technique for doing just this. The
[memo_wise](https://github.com/panorama-ed/memo_wise) gem may be useful for
more complex memoizations.


```ruby
# This gene generates a random hexidecimal color code for use by evolvables.

require 'securerandom'

class ColorGene
  include Evolvable::Gene

  def hex_code
    @hex_code ||= SecureRandom.hex(3)
  end
end
```


[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Gene)

## Populations
Population objects are responsible for generating and evolving instances.
They orchestrate all the other Evolvable objects to do so.

Populations can be initialized and re-initialized with a number of useful
parameters.


```ruby
# TODO: initialize a population with all supported parameters
```


[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Population)

## Evaluation
For selection to be effective in the context of evolution, there needs to be
a way to compare evolvables. In the genetic algorithm, this is often
referred to as the "fitness function".

The `Evolvable::Evaluation` object expects evolvable instances to define a `#value` method that
returns some numeric value. Values are used to evaluate instances relative to each
other and with regards to some goal. Out of the box, the goal can be set
to maximize, minimize, or equalize numeric values.


```ruby
# TODO: Show how to add/change population's evaluation object

# The goal value can also be assigned via as argument to `Evolvable::Population#evolve`
population.evolve(goal_value: 1000)
```


[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Evaluation)

## Evolution
After a population's instances are evaluated, they undergo evolution.
The default evolution object is composed of selection,
crossover, and mutation objects and applies them as operations to
a population's evolvables in that order.


[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Evolution)

## Selection
The selection object assumes that a population's evolvables have already
been sorted by the evaluation object. It selects "parent" evolvables to
undergo combination and thereby produce the next generation of evolvables.

Only two evolvables are selected as parents for each generation by default.
The selection size is configurable.


```ruby
# TODO: Show how to add/change population's selection object
```



[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Selection)

## Combination
Combination generates new evolvable instances by combining the genes of selected instances.
You can think of it as a mixing of parent genes from one generation to
produce the next generation.

You may choose from a selection of combination objects or implement your own.
The default combination object is `Evolvable::GeneCombination`.


[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Combination)

## Mutation
Mutation serves the role of increasing genetic variation. When an evolvable
undergoes a mutation, one or more of its genes are replaced by newly
initialized ones. In effect, a gene mutation invokes a new random outcome
from the genetic search space.

Mutation frequency is configurable using the `probability` and `rate`
parameters.


```ruby
# Show how to initialize/assign population with a specific mutation object
```


[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Mutation)

## Search Space
The search space encapsulates the range of possible genes
for a particular evolvable. You can think of it as the boundaries of
genetic variation. It is configured via the
[.search_space](#evolvableclasssearch_space) method that you define
on your evolvable class. It's used by populations to initialize
new evolvables.

Evolvable provides flexibility in how you define your search space.
The below example implementations for `.search_space` produce the
exact same search space for the
[Hello World](https://github.com/mattruzicka/evolvable#hello-world)
demo program. The different styles arguably vary in suitability for
different contexts, perhaps depending on how programs are loaded and
the number of different gene types.


```ruby
# All 9 of these example definitions are equivalent

# Hash syntax
{ chars: { type: 'CharGene', max_count: 100 } }
{ chars: { type: 'CharGene', min_count: 1, max_count: 100 } }
{ chars: { type: 'CharGene', count: 1..100 } }

# Array of arrays syntax
[[:chars, 'CharGene', 1..100]]
[['chars', 'CharGene',  1..100]]
[['CharGene', 1..100]]

# A single array works when there's only one type of gene
['CharGene', 1..100]
[:chars, 'CharGene', 1..100]
['chars', 'CharGene', 1..100]
```


[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/SearchSpace)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattruzicka/evolvable.

If you're interested in contributing, but don't know where to get started, message me on twitter at [@mattruzicka](https://twitter.com/mattruzicka).