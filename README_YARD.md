# Evolvable 🦎

[![Gem Version](https://badge.fury.io/rb/evolvable.svg)](https://badge.fury.io/rb/evolvable) [![Maintainability](https://api.codeclimate.com/v1/badges/7faf84a6d467718b33c0/maintainability)](https://codeclimate.com/github/mattruzicka/evolvable/maintainability)

An evolutionary framework for writing programs that use operations such as selection, combination, and mutation. Explore ideas generatively in any domain, discover novel solutions to complex problems, and build intuitions about intelligence, complexity, and the natural world.

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
* [Gene Space](#gene-space)


## Installation

Add [gem "evolvable"](https://rubygems.org/gems/evolvable) to your Gemfile and run `bundle install` or install it yourself with: `gem install evolvable`

## Getting Started

{@readme Evolvable}

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

Now we can **define the `.gene_space`** class method with the types of [genes](#genes) that we want our our evolvable "hello world" instances to be able to have. We'll use `CharGene` instances to represent single characters within strings. So an instance with the string value of "Hello" would be composed of five `CharGene` instances.

```ruby
class HelloWorld
  include Evolvable

  def self.gene_space
    ["CharGene", 1..40]
  end
end
```

The [Gene Space](#gene-space) can be defined in a variety of ways. The above is shorthand that's useful for when there's only one type of gene. This method can also return an array of arrays or hash.

The `1..40` specifies the range of possible genes for a particular HelloWorld instance. Evolvable translates this range or integer value into a `Evolvable::CountGene` object.

By specifying a range, an `Evolvable::CountGene` instance can change the number of genes that are present in an evovlable instance. Count genes undergo evolutionary operations like any other gene. Their effects can be seen in the letter changes from Generation 165 to 168 in the above example output.

To finish step 2, we'll **define the gene class** that we referenced in the above `.gene_space` method. Gene classes should include the `Evolvable::Gene` module.

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

After defining the gene space, we can now initialize `HelloWorld` instances with random genes, but to actually evolve them, we need to **define the `#value` instance method**. It provides the basis for comparing different evolvable instances.

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

1. `.before_evaluation(population)` - {@readme Evolvable::ClassMethods#before_evaluation}
2. `.before_evolution(population)`- {@readme Evolvable::ClassMethods#before_evolution}
3. `.after_evolution(population)` - {@readme Evolvable::ClassMethods#after_evolution}

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

[Populations](#populations) are composed of evolvables which are composed of genes. Evolvables orchestrate behaviors by delegating to gene objects. Collections of genes are organized into genomes and constitute the [gene space](#gene-space). [Evaluation](#evaluation) and [evolution](#evolution) objects are used to evolve populations. By default, evolution is composed of [selection](#selection), [combination](#combination), and [mutation](#mutation).

The following concept map depicts how genes flow through populations.

![Concept Map](https://github.com/mattruzicka/evolvable/raw/main/examples/images/diagram.png)

Evolvable is designed with extensibility in mind. Evolvable objects such as [evaluation](#evaluation), [evolution](#evolution), [selection](#selection), [combination](#combination), and [mutation](#mutation) can be extended and swapped, potentially in ways that alter the above graph.

## Genes
{@readme Evolvable::Gene}

{@example Evolvable::Gene}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Gene)

## Populations
{@readme Evolvable::Population}

{@example Evolvable::Population}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Population)

## Evaluation
{@readme Evolvable::Evaluation}

{@example Evolvable::Evaluation}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Evaluation)

## Evolution
{@readme Evolvable::Evolution}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Evolution)

## Selection
{@readme Evolvable::Selection}

{@example Evolvable::Selection}


[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Selection)

## Combination
{@readme Evolvable::GeneCombination}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Combination)

## Mutation
{@readme Evolvable::Mutation}

{@example Evolvable::Mutation}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Mutation)

## Gene Space
{@readme Evolvable::GeneSpace}

{@example Evolvable::GeneSpace}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/GeneSpace)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattruzicka/evolvable.

If you're interested in contributing, but don't know where to get started, message me on twitter at [@mattruzicka](https://twitter.com/mattruzicka).