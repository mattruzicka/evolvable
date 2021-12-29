# Evolvable 🦎

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
* [Populations](#populations)
* [Evaluation](#evaluation)
* [Evolution](#evolution)
* [Selection](#selection)
* [Combination](#combination)
* [Mutation](#mutation)
* [Search Space](#search-space)

## Getting Started

{@readme Evolvable}

To demonstrate these steps, we'll look at the [Hello World](#) example program.

### Hello World

The goal of this program is to evolve a population of arbitrary strings to be more like any given target string. Try running `evolvable hello` at the command line to see it in action.

Below is example output from evolving a population of random initialized string objects to match "Hello World!", then "Hello Evolvable World".

```
Enter a string to evolve: Hello World!

pp`W^jXG'_N`%              Generation 0
H-OQXZ\a~{H*               Generation 1 ...
HRv9X WorlNi               Generation 50 ...
HRl6W World#               Generation 100 ...
Hello World!               Generation 165

Enter a string to evolve: Hello Evolvable World

Helgo World!b+=1}3         Generation 165
Helgo Worlv!}:c(SoV        Generation 166
Helgo WorlvsC`X(Joqs       Generation 167
Helgo WorlvsC`X(So1RE      Generation 168 ...
Hello Evolv#"l{ Wor*5      Generation 300 ...
Hello Evolvable World      Generation 388
```

To implement this program, let's first define the `HelloWorld` class and **include the `Evolvable` module**.

```ruby
class HelloWorld
  include Evolvable
end
```

Next we **define the `.search_space`** class method with the types of [genes](#genes) that we want our our evolvable "hello world" instances to be able to have. We'll use `CharGene` instances to represent single characters within strings. So an instance with the string value of "Hello" would be composed of five `CharGene` instances.

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

By specifying a range, an `Evolvable::CountGene` instance can change the number of genes that are present in an evovlable instance by undergoing evolutionary operations like any other gene. The effects of the count gene can be seen in the changes from Generation 165 to 168 in the above example output.

Now we'll **define the gene class** that we referenced in the above `.search_space` method. Gene classes should include the `Evolvable::Gene` module.

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

It's important that, once accessed, the data for a particular gene never change. When the `#to_s` method first runs, Ruby's `||=` operator memoizes the result of randomly picking a char, so that this method always returns the same char from the same gene instance.

After defining the search space, we can now initialize `HelloWorld` instances with random genes, but to actually evolve them, we need to **define the `#value` instance method**. It provides the basis for comparing different evolvable instances.

As we'll see in the next step, the goal value is set to 0 for this program. This means we want the `#value` method to return numbers that are closer to 0 when instances more closely match our target value. For example, if our target is "hello world", an instance that returns "jello world" would have a value of 1 and "hello world" would have a value of 0.

We'll leave implementing `#value` as an exercise for the reader, or you can check out the example implementation in [examples/hello_world.rb](https://github.com/mattruzicka/evolvable/blob/main/examples/hello_world.rb)

Now it's time to **initialize a population with `.new_population`**. By default, our population seeks to maximize values. In this program, we always know the best possible value, so setting the goal to a concrete number makes sense. We'll also specify the number of instances in a population using the `size` paramater and change the `mutation_probability` from 0.03 (3%) to 0.6 (60%).

For this example, a large `mutation_probability` tends to decrease the time it takes to evolve matches with short strings and the opposite for long strings. This is demonstrated in the example output above by how many generations it took to go from "Hello World!" to "Hello Evolvable World". We could dynamically change the `mutation_probability` by hooking into one of the population hooks detailed below, but doing so is currently beyond the scope of this tutorial.

```ruby
population = HelloWorld.new_population(size: 100,
                                       evaluation: { equalize: 0 },
                                       mutation: { probability: 0.6 })
```

At this point, we could run `population.evolve` and everything should work, but we wouldn't receive any feedback.

### Evolvable Population Hooks

The following class methods can be implemented on your Evolvable class to hook into the Population#evolve lifecycle. This is useful for outputing evolutionary progress, optimizing parameters, and creating interactions with and between evolvable instances.

1. `.before_evaluation(population)` - {@readme Evolvable::ClassMethods#before_evaluation}
2. `.before_evolution(population)`- {@readme Evolvable::ClassMethods#before_evolution}
3. `.after_evolution(population)` - {@readme Evolvable::ClassMethods#after_evolution}

Let's define `.before_evolution` to print the best value for each generation. We'll also define `#to_s` which is implicitly invoked during string interpolation, as is `CharGene#to_s` when we use `#join`.

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

You now know the fundamental steps to building evolvable programs of endless complexity in any domain! 🐸

The exact implementation for the command line demo can be found in [exe/hello](https://github.com/mattruzicka/evolvable/blob/main/exe/hello) and [examples/hello_world.rb](https://github.com/mattruzicka/evolvable/blob/main/examples/hello_world.rb).

## Concepts

[Populations](#populations) are composed of evolvables which are composed of genes. Evolvables orchestrate behaviors by delegating to gene objects. Collections of genes are organized into genomes and constitute the [search space](#search-space). [Evaluation](#evaluation) and [evolution](#evolution) objects are used to evolve populations. By default, evolution is composed of [selection](#selection), [combination](#combination), and [mutation](#mutation).

The following concept map depicts how genes flow through populations.

![Concept Map](https://github.com/mattruzicka/evolvable/raw/main/examples/images/diagram.png)

Evolvable is designed with extensibility in mind. Evolvable objects such as [evaluation](#evaluation), [evolution](#evolution), [selection](#selection), [combination](#combination), and [mutation](#mutation) can be extended and swapped, potentially in a way that alters the above graph.

## Genes
{@readme Evolvable::Gene}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Gene)

## Populations
{@readme Evolvable::Population}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Population)

## Evaluation
{@readme Evolvable::Evaluation}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Evaluation)

## Evolution
{@readme Evolvable::Evolution}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Evolution)

## Selection
{@readme Evolvable::Selection}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Selection)

## Combination
{@readme Evolvable::GeneCombination}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Combination)

## Mutation
{@readme Evolvable::Mutation}

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/Mutation)

## Search Space
{@readme Evolvable::SearchSpace}

Evolvable provides flexibility in how you define your search space. The following example implementations for `.search_space` produce the exact same search space for the [Hello World](#hello-world) demo program. The different styles arguably vary in suitability for different contexts, perhaps depending on how programs are loaded and the number of different gene types.

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

[Documentation](https://rubydoc.info/github/mattruzicka/evolvable/Evolvable/SearchSpace)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattruzicka/evolvable.

If you're interested in contributing, but don't know where to get started, feel free to message me on twitter at [@mattruzicka](https://twitter.com/mattruzicka).