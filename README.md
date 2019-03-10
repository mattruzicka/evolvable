# Evolvable

Genetic algorithms mimic biological processes such as natural selection, crossover, and mutation to model evolutionary behaviors in code. The "evolvable" gem can add evolutionary behavior to any Ruby object.

If you're interested in seeing exactly how the "evolvable" gem evolves populations of Ruby objects, I suggest opening up the [Population](https://github.com/mattruzicka/evolvable/blob/master/lib/evolvable/population.rb) class, specifically check out the following methods:

- ```evolve!```
- ```evaluate_objects!```
- ```select_objects!```
- ```crossover_objects!```
- ```mutate_objects!```

## Usage

To introduce evolvable behavior to any Ruby object, do the following:

1. Include the Evolvable module
2. Define a class method named ```evolvable_gene_pool```
3. Define an instance method named ```fitness```

For example, let's say we want to make a text-to-speech command evolve from saying random nonsense to saying whatever you desire.

```Ruby
require 'evolvable'

class Sentence
  include Evolvable

  DICTIONARY = ('a'..'z').to_a << ' '
  DESIRED_WORDS = 'colorless green ideas sleep furiously'

  def self.evolvable_gene_pool
    Array.new(DESIRED_WORDS.length) { |index| [index, DICTIONARY] }
  end

  def fitness
    score = 0
    @genes.values.each_with_index do |value, index|
      score += 1 if value == DESIRED_WORDS[index]
    end
    score
  end

  def words
    @genes.values.join
  end
end
```

Now let's listen to our computer evolve its speech. The following code assumes your system has a text-to-speech command named "say" installed. Run this code in irb:

```ruby
population = Sentence.evolvable_population
object = population.strongest_object

until object.fitness == Sentence::DESIRED_WORDS.length
  puts object.words
  system("say #{object.words}")
  population.evolve!(fitness_goal: Sentence::DESIRED_WORDS.length)
  object = population.strongest_object
end
```

To play with a more interactive version, check out https://github.com/mattruzicka/evolvable_sentence

### The Gene Pool

TODO: add descriptions and examples for following

```.evolvable_gene_pool```

```.evolvable_genes_count```

### Fitness

TODO: add description and example

### Custom Evolvable Class Methods

TODO: add descriptions and example implementations for the following

```.evolvable_evaluate!(objects)```

```.evolvable_population(args = {})```

```.evolvable_population_attrs```

```.evolvable_initialize(genes, population, object_index)```

### Hooks

TODO: add description

```.evolvable_before_evolution(population)```

```.evolvable_after_select(population)```

```.evolvable_after_evolution(population)```

### Custom Mutations

TODO: Show how to define and use a custom mutation object

### Custom Crossover

TODO: Show how to define and use a custom crossover object

### Helper Methods

TODO: add description

```Evolvable.combine_dimensions(dimensions)```

### Configuration

TODO: Make logger configurable and make it smarter about picking a default

## Demos

https://github.com/mattruzicka/evolvable_sentence
- A more interactive version of the evolvable sentence code above.

https://github.com/mattruzicka/evolvable_equation
- Evolves an equation of a specified length to evaluate to a given number.

More demos to come...

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'evolvable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install evolvable

## Development

After checking out the repo, run `bundle install` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

I am looking to both simplify how genes are defined as well as support more complex gene types by way of a new Gene class. Currently, genes are represented as an array of arrays or hashes depending on the context. This will likely change.

I would also like to make more obvious how an evolvable object's genes can influence its behavior/fitness with well-defined pattern for gene expression, probably via an instance method on a gene called "express".

I have a general sense of how I want to move forward on these features, but feel free to message me with ideas or implementations.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/evolvable.
