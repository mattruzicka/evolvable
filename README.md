# Evolvable 🧬

[![Gem Version](https://badge.fury.io/rb/evolvable.svg)](https://badge.fury.io/rb/evolvable) [![Maintainability](https://api.codeclimate.com/v1/badges/7faf84a6d467718b33c0/maintainability)](https://codeclimate.com/github/mattruzicka/evolvable/maintainability)

---

⚠️ **This README is for a not-yet-released version of Evolvable, likely 1.1.0**

Please use this `main` branch and give me feedback as I work on polishing things up and cutting the next release!

---


An evolutionary framework for writing programs that use operations such as selection, crossover, and mutation. Explore ideas generatively in any domain, discover novel solutions to complex problems, and build intuitions about intelligence, complexity, and the natural world.

Subscribe to the [Evolvable Newsletter](https://www.evolvable.site/newsletter) to slowly learn more, or keep reading this contextualization of the [full documentation](https://rubydoc.info/github/mattruzicka/evolvable).


## Table of Contents
* [Getting Started](#getting-started)
* [Concepts](#concepts)
* [Genes](#genes)
* [Populations](populations)
* [Evaluation](#evaluation)
* [Evolution](#evolution)
* [Selection](#selection)
* [Combination](#combination)
* [Mutation](#mutation)
* [Search Space](#search-space)

## Getting Started

The `Evolvable` module makes it possible to implement evolutionary behaviors for
any class by defining a `.search_space` class method and `#value` instance method.
To evolve instances, initialize a population with `.new_population` and use the
`Evolvable::Population#evolve` instance method.

1. [Include the `Evolvable` module in the class you want to evolve.](https://rubydoc.info/github/mattruzicka/Evolvable)
2. [Define `.search_space` and any gene classes that you reference.](https://rubydoc.info/github/mattruzicka/Evolvable/SearchSpace)
3. [Define `#value`.](https://rubydoc.info/github/mattruzicka/Evolvable/Evaluation)
4. [Initialize a population with `.new_population` and use `#evolve`.](https://rubydoc.info/github/mattruzicka/Evolvable/Population)


### Hello World

To demonstrate these steps, we'll highlight the [Hello World](#) example program. Its goal is to evolve a population of arbitrary strings to be more like some target string. You can use with the command line demo by running `evolvable hello`. Below is example output from evolving a population of random strings to match "Hello World!", then "Hello Evolvable World".

```
pp`W^jXG'_N`%              Generation 0
H-OQXZ\a~{H*               Generation 1
HRv9X WorlNi               Generation 50
HRl6W World#               Generation 100
Hello World!               Generation 165

Enter a string to evolve: Hello Evolvable World

Helgo World!b+=1}3         Generation 165
Helgo Worlv!}:c(SoV        Generation 166
Helgo WorlvsC`X(Joqs       Generation 167
Helgo WorlvsC`X(So1RE      Generation 168
Hello Evolv#"l{ Wor*5      Generation 300
Hello Evolvable World      Generation 388
```

To start, we'll define the `HelloWorld` class and **include the `Evolvable` module**.

```ruby
class HelloWorld
  include Evolvable
end
```

The next step is to **define the `.search_space`** class method which defines the range of [genes](#genes) that are available to our evolvable "hello world" instances. The [Search Space](#search-space) can be defined in a variety of ways. This example uses a shorthand syntax that's convenient when there's one type of gene. In our example, each gene will represent a single character.

```ruby
class HelloWorld
  include Evolvable

  def self.search_space
    ["CharGene", 1..100]
  end
end
```

The `1..100` specifies the range of possible genes for a particular evolvable HelloWorld instance. Evolvable translates this count definition into a `Evolvable::CountGene` object which undergoes evolutionary operations like any other gene. The effect of the count gene seen in the example output above, particularly in the changes from Generation 165 to 168.


Now we'll **define the gene class** that we referenced in the above `.search_space` method. Gene classes should include the `Evolvable::Gene` module. When the `#to_s` method below is first used, Ruby's `||=` operator memoizes the result of randomly picking a char, so that he same char continues to be returned. It's important that, once accessed, the data for a particular gene never change.

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

Now that we've defined the search space, we can now initialize `HelloWorld` instances with random genes, but to actually evolve them, we need to **define the `#value` instance method** which provides the basis for comparing different evolvable instances with each other.

For this program, the goal value is set to 0. This means we want the `#value` method to return numbers that are closer to 0 when instances more closely match our target value. If our target is "hello world", for example, an instance that produces "jello world" would have a value of 1 and "hello world" would have a vlaue of 0. Check out the full `HelloWorld` implementation at [examples/hello_world.rb](https://github.com/mattruzicka/evolvable/blob/main/examples/hello_world.rb).


Now it's time to **initialize a population with `.new_population`**. By default, our population seeks to maximize values. For this contrived example, we always know the best possible value, so setting the goal to a concrete number makes sense. We'll also specify the number of instances in a population using the `size` paramater and change the `mutation_probability` from 0.03 (3%) to 0.6 (60%).


```ruby
evaluation = Evolvable::Evaluation.new(equalize: 0)
population = HelloWorld.new_population(size: 100, evaluation: evaluation)
population.mutation_probability = 0.6
```

For this application, a large `mutation_probability` can be speed up evolutionary time for shorter target strings, but tends to be a liability for longer ones. This is demonstrated in the example output above by how many generations it took to go from "Hello World!" to "Hello Evolvable World".

Luckily, it's easy to dynamically change configurations by defining the following class method hooks whcih accept `population` as an argument.

### Evolvable Population Hooks

1. `.before_evaluation` - Runs before evaluation.

2. `.before_evolution`- Runs after evaluation and before evolution.

3. `.after_evolution` - Runs after evolution.


This program uses `.before_evolution` to print the best value for each generation.

```ruby
class HelloWorld
  include Evolvable

  def self.before_evolution(population)
    best_evolvable = population.best_evolvable
    evolutions_count = population.evolutions_count
    puts "#{best_evolvable} - Generation #{evolutions_count}"
  end

  # ...
end
```

In this way, this HelloWorld demo can be optimized by experimenting with population parameters such as `size`, `goal`, `selection_size`, `mutation_rate`, `mutation_probability`. [Pull Requests are welcome](Contributing)

Finally we can **evolve the population with the `Evolvable::Population#evolve` instance method**.

```ruby
population.evolve
```


## Concepts

[Populations](#populations) are composed of evolvables. Evolvables are instances of classes that include the `Evolvable` module and are composed of [genes](#genes) that include the `Evolvable::Gene` module. Genes constitute the [search space](#search-space). Evolvables delegate to gene objects to orchestrate behaviors. [Evaluation](#evaluation) and [evolution](#evolution) objects are used to evolve populations. By default, evolution is composed of [selection](#selection), [combination](#combination), and [mutation](#mutation).

The Evolvable framework is designed with extensibility in mind. The core objects used such as [evaluation](#evaluation), [evolution](#evolution), [selection](#selection), [combination](#combination), and [mutation](#mutation) can be extended and swapped.

![Concept Map](https://github.com/mattruzicka/evolvable/raw/main/examples/images/diagram.png)

## Genes
For evolution to be effective, an evolvable's genes must be able to influence
its behavior. Evolvable instances are composed of genes which can be used
to implement simple functions or orchestrate complex interactions.

Defining gene classes requires encapsulating some "sample space" and returning
a sample outcome when a gene attribute is accessed. For evolution to proceed
in a non-random way, the same sample outcome should be returned every time
a particular gene is accessed with a particular set of parameters.
Memoization is a useful technique for doing just this. Check out the
[memo_wise](https://github.com/panorama-ed/memo_wise) gem.


[Documentation](https://rubydoc.info/github/mattruzicka/Evolvable/Gene)

## Populations
Population objects are responsible for generating and evolving instances.
They orchestrate all the other Evolvable objects to do so.

Populations can be initialized and re-initialized with a number of useful
parameters.


[Documentation](https://rubydoc.info/github/mattruzicka/Evolvable/Population)

## Evaluation
For selection to be effective in the context of evolution, there needs to be
a way to compare evolvables. In the genetic algorithm, this is often
referred to as the "fitness function".

The Evaluation object expects evolvable instances to define a `#value` method that
returns some numeric value. Values are used to evaluate instances relative to each
other and with regards to some goal. Out of the box, the goal can be
to maximize, minimize, or equalize some numeric value.


[Documentation](https://rubydoc.info/github/mattruzicka/Evolvable/Evaluation)

## Evolution
After a population's instances are evaluated, they undergo evolution.
The default evolution object is composed of selection,
crossover, and mutation objects and applies them as operations to
a population's evolvables in that order.


[Documentation](https://rubydoc.info/github/mattruzicka/Evolvable/Evolution)

## Selection
The selection object assumes that a population's evolvables have already
been sorted by the evaluation object. It selects "parent" evolvables to
undergo combination and thereby produce the next generation of evolvables.

Only two evolvables are selected as parents for each generation by default.
The selection `size` is configurable.


[Documentation](https://rubydoc.info/github/mattruzicka/Evolvable/Selection)

## Combination
Combination generates new evolvable instances by combining the genes of selected instances.
You can think of it as a mixing of parent genes from one generation to
produce the next generation.


[Documentation](https://rubydoc.info/github/mattruzicka/Evolvable/Combination)

## Mutation
Mutation serves the role of increasing genetic variation. When an evolvable
undergoes a mutation, one or more of its genes are replaced by newly
initialized ones. In effect, a gene mutation invokes a new random outcome
from the genetic search space.

Mutation frequency is configurable using the `probability` and `rate`
parameters.


[Documentation](https://rubydoc.info/github/mattruzicka/Evolvable/Mutation)

## Search Space
The Search Space encapsulates the range of possible genes
for a particular evolvable. It is configured via the
[EvolvableClass.search_space](#evolvableclasssearch_space) method
and used by populations to initialize new instances.


Evolvable provides flexibility in how you define your search space. The following examples implementations for `.search_space` produce the exact same search space for the [Hello World](#hello-world) demo program. The different styles arguably vary in suitability for different contexts, perhaps depending on how programs are loaded and the number of different gene types.

**Hash**

```ruby
{ chars: { type: 'CharGene', max_count: 100 } }
```
```ruby
{ chars: { type: 'CharGene', min_count: 1, max_count: 100 } }
```
```ruby
{ chars: { type: 'CharGene', count: 1..100 } }
```

**Array of arrays**

```ruby
[[:chars, 'CharGene', 1..100]]
```
```ruby
[['chars', 'CharGene',  1..100]]
```
```ruby
[['CharGene', 1..100]]
```

**Single array for when there's only one type of gene**

```ruby
['CharGene', 1..100]
```
```ruby
[:chars, 'CharGene', 1..100]
```
```ruby
['chars', 'CharGene', 1..100]
```




[Documentation](https://rubydoc.info/github/mattruzicka/Evolvable/SearchSpace)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattruzicka/evolvable.

If you're interested in contributing, but don't know where to get started, feel free to message me on twitter at [@mattruzicka](https://twitter.com/mattruzicka).