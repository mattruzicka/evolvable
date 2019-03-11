# Evolvable

Genetic algorithms mimic biological processes such as natural selection, crossover, and mutation to model evolutionary behaviors in code. This gem can add evolutionary behaviors to any Ruby object.

## Demos

- [Evolvable Sentence](https://github.com/mattruzicka/evolvable_sentence) - An interactive version of the evolvable sentence example in "Getting Started"
- [Evolvable Equation](https://github.com/mattruzicka/evolvable_equation) - Evolves an equation of a specified length to evaluate to a given number

## Usage

- [Getting Started](#Getting-Started)
- [The Gene Pool](#The-Gene-Pool)
- [Fitness](#Fitness)
- [Evolvable Population](#Evolvable-Population)
- [Monitoring Progress](#Monitoring-Progress)
- [Hooks](#Hooks)
- [Mutation Objects](#Mutation-Objects)
- [Crossover Objects](#Crossover-Objects)
- [Helper Methods](#Helper-Methods)
- [Configuration](#Configuration)

### Getting Started

To build an object with evolvable behavior, do the following:

1. Add ```include Evolvable``` to your class
2. Define ```.evolvable_gene_pool``` ([documentation](#The-Gene-Pool))
3. Define ```#fitness``` ([documentation](#Fitness))

As an example, let's make a text-to-speech command evolve from saying random nonsense to whatever you desire. We'll start by defining a Sentence class and doing the three steps above:

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
end
```

Now let's listen to our computer evolve its speech. The following code assumes your system has a text-to-speech command named "say" installed. Run this code in irb:

```ruby
# To play with a more interactive version, check out https://github.com/mattruzicka/evolvable_sentence

population = Sentence.evolvable_population
object = population.strongest_object

until object.fitness == Sentence::DESIRED_WORDS.length
  words = object.genes.values.join
  puts words
  system("say #{words}")
  population.evolve!(fitness_goal: Sentence::DESIRED_WORDS.length)
  object = population.strongest_object
end

```

The ```Evolvable::Population#evolve!``` method evolves the population from one generation to the next. It accepts two optional keyword arguments:

```ruby
{ generations_count: 1, fitness_goal: nil }
```

Specifying the **fitness_goal** is useful when there's a known fitness you're trying to achieve. We use it in the evolvable sentence example above. If you want your population to keep evolving until it hits a particular fitness goal, set **generations_count** to a large number. The **generations_count** keyword argument tells ```#evolve!``` how many times to run.

If you're interested in seeing exactly how ```Evolvable::Population#evolve!``` works, Open up the [Population](https://github.com/mattruzicka/evolvable/blob/master/lib/evolvable/population.rb) class and check out the following methods:

- ```evaluate_objects!```
- ```select_objects!```
- ```crossover_objects!```
- ```mutate_objects!```

### The Gene Pool

Currently, the gene pool needs to be an array of arrays. Each inner array contains a gene name and an array of possible values for the gene. Expect future releases to make defining the gene pool more straightforward. Check out [Development](#Development) below for details. Until then, here's an example of a simple ```.evolvable_gene_pool``` definition for evolvable dueling pianos:

```ruby
class DualingPianos
  NOTES = ['C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B']

  def self.evolvable_gene_pool
    [[:piano_1, NOTES],
     [:piano_2, NOTES]]
  end
end
```

The number of potential genes in the gene pool can be extremely large. For these cases, "Evolvable" makes it possible for objects to contain only a subset of genes with the ```.evolvable_genes_count``` method. Any gene defined in the ```.evolvable_gene_pool``` can still manifest during mutations. In this way, we can limit the gene size of particular objects without limiting the genes available to a population.

```ruby
require 'evolvable'

class ComplexBot
  include Evolvable

  def self.evolvable_gene_pool
    potential_gene_values = (1..10_000).to_a
    Array.new(1_000_000) { |n| [n, potential_gene_values] }
  end

  def self.evolvable_genes_count
    5_000
  end
end

ComplexBot.evolvable_gene_pool.size # => 1_000_000
population = ComplexBot.evolvable_population
complex_bot = population.objects.first
complex_bot.genes.count # => 10_000
```

### Fitness

The ```#fitness``` method is responsible for measuring how well an object performs. It returns a value or "score" which influences whether an object will be selected to "breed" the next generation of objects. How fitness is defined depends on what you're trying to achieve. If you're trying to break a high score record in Tetris, for example, then the fitness function for your tetris bot might simply return its tetris score:

```ruby
class TetrisBot
  alias fitness tetris_score
end
```

If, however, your aim is to construct a bot that plays Tetris in an aesthetically pleasing way, maybe you'd define fitness by surveying your artist friends.

```ruby
class TetrisArtBot
  def fitness
    artist_friend_ratings.sum / artist_friend_ratings.count
  end
end
```

The result of ```#fitness``` can be any object that includes the ([Comparable](https://ruby-doc.org/core-2.6.1/Comparable.html)) mixin from Ruby and implements the ```<=>``` method. Many Ruby classes such as String and Integer have default implementations.

You may want to evaluate a whole generation of objects at once. For example, maybe you want each of your bots to play a game against each other and base your fitness score off their win records. For this case, use ```.evolvable_evaluate!(objects)``` like so: 

```ruby
class GamerBot
  def self.evolvable_evaluate!(objects)
    objects.combination(2).each do |player_1, player_2|
      winner = Game.play(player_1, player_2)
      winner.win_count += 1
    end
  end

  alias fitness win_count
end
```

### Evolvable Population

The Evolvable::Population class can be initialized in two ways

1. ```EvolvableBot.evolvable_population```
2. ```Evolvable::Population.new(evolvable_class: EvolvableBot)```


Both ways accept the following keyword arguments as defined by ```Evolvable::Population#initialize```
```ruby
{ evolvable_class:, # Required. Inferred if you use the .evolvable_population method
  size: 20, # The number of objects in each generation
  selection_count: 2, # The number of objects to be selected as parents for crossover
  crossover: Crossover.new, # Any object that implements #call
  mutation: Mutation.new, # Any object that implements #call!
  generation_count: 0, # Useful when you want to re-initialize a previously saved population of objects
  objects: [], # Ditto
  log_progress: false } # See the "Monitoring Progress" section for details
```

The ```.evolvable_population(args = {})``` method merges any given args with with any keyword arguments defined in ```.evolvable_population_attrs```. To illustrate:

```ruby
class Plant
  include Evolvable

  def self.evolvable_population_attrs
  { size: 100,
    selection_count: 5,
    mutation: Evolvable::Mutation.new(rate: 0.3),
    log_progress: false }
  end

  def self.evolvable_gene_pool
    [[:leaf_count, (1..100).to_a],
     [:root_type, ['fibrous', 'taproot']]]
  end
end

population = Plant.evolvable_population(log_progress: true)
population.size # => 100
population.selection_count # => 5
population.mutation.rate # => 0.3
population.log_progress # => true
```

The ```.evolvable_initialize(genes, population, object_index)``` method is used by Evolvable::Population to initialize new objects. You can override it to control how your objects are initialized. Make sure to assign the passed in **genes** to your initialized objects. Here's an example implementation for when you want your imaginary friends to have names:

```ruby
class ImaginaryFriend
  def self.evolvable_initialize(genes, population, object_index)
    friend = new(name: BABY_NAMES.sample)
    friend.genes = genes
    friend.population = population
    friend
  end
end
```

The third argument to ```.evolvable_initialize``` is the index of the object in the population before being evaluated. It is useful when you what to give your objects more utilitarian names:

```ruby
friend.name == "#{name} #{population.generation_count}.#{object_index}" # => "ImaginaryFriend 0.11"
```

A time when you'd want to use Evolvable::Population initializer instead of ```EvolvableBot.evolvable_population``` is when you're re-initializing a population. For example, maybe you want to continue evolving a population of chat bots that you had previously saved to a database:

```ruby
population = load_chat_bot_population
Evolvable::Population.new(evolvable_class: population.evolvable_class,
                          size: population.size,
                          selection_count: population.selection_count,
                          crossover: population.crossover,
                          mutation: population.mutation,
                          generation_count: population.generation_count,
                          objects: population.objects)
```

### Monitoring Progress

The ```#evolvable_progress``` method is used by ```Evolvable::Population#evolve!``` to log the progress of the "strongest object" in each generation. That is, the object with the best fitness score. It runs just after objects are evaluated and the ```Evolvable::Population#strongest_object``` can be determined. ```Evolvable::Population#log_progress``` must equal true in order for the result of the ```#evolvable_progress``` to be logged.

In the [evolvable sentence demo](https://github.com/mattruzicka/evolvable_sentence), ```evolvable_progress``` is implemented in order to output the strongest object's generation count, fitness score, and words. In this example, we also use the "say" text-to-speech command to pronounce the words. 

```Ruby
  class Sentence
    def evolvable_progress
      words = @genes.values.join
      puts "Generation: #{population.generation_count} | Fitness: #{fitness} | #{words}"
      system("say #{words}") if say?
    end
  end
  population.log_progress = true
```

Hooks can also be used to monitor progress.

### Hooks

You can define any the following class method hooks on any Evolvable class. They run during the evolution of each generation in ```Evolvable::Population#evolve!```

```.evolvable_before_evolution(population)```

```.evolvable_after_select(population)```

```.evolvable_after_evolution(population)```

### Mutation Objects

The [Evolvable::Mutation](https://github.com/mattruzicka/evolvable/blob/master/lib/evolvable/mutation.rb) class defines the default mutation implementation with a default mutation rate of 0.03. It can be initialized with a custom mutation rate like so:

```ruby
mutation = Evolvable::Mutation.new(rate: 0.05)
population = Evolvable::Population.new(mutation: mutation)
population.evolve!
```

Any Ruby object that implements ```#call!(objects)``` can be used as a mutation object. The default implementation is specialized to work with evolvable objects that define a ```evolvable_genes_count``` that is less than ```evolvable_gene_pool.size```. For more information on this, see [The Gene Pool](#The-Gene-Pool)

### Crossover Objects

The [Evolvable::Crossover](https://github.com/mattruzicka/evolvable/blob/master/lib/evolvable/crossover.rb) class defines the default crossover implementation.

```ruby
crossover = Evolvable::Crossover.new
population = Evolvable::Population.new(crossover: crossover)
population.evolve!
```

Any Ruby object that implements ```#call(parent_genes, offspring_count)``` can be used as a crossover object. The default implementation is specialized to work with evolvable objects that define a ```evolvable_genes_count``` that is less than ```evolvable_gene_pool.size```. For more information on this, see [The Gene Pool](#The-Gene-Pool)

### Helper Methods

```Evolvable.combine_dimensions(dimensions)```

This is helpful when you want to create, for lack of a better word, "multidimensional genes". In the following example, we want our fortune cookie to evolve fortunes based on its eater's hair and eye color because fortune cookies understand things that we aren't capable of knowing.

```ruby
class FortuneCookie
  include Evolvable

  HAIR_COLORS = ['black', 'blond', 'brown', 'gray', 'red', 'white']
  EYE_COLORS = ['blue', 'brown', 'gray', 'green']
 
  FORTUNES = ['You will prosper',
              'You will endure hardship',
              'You are about to eat a crisp and sugary cookie']

  def self.evolvable_gene_pool
    gene_names_array = Evolvable.combine_dimensions([HAIR_COLORS, EYE_COLORS])
    gene_names_array.map! { |gene_name| [gene_name, FORTUNES] }
  end

  def fitness
    hair_color = find_eater_hair_color
    eye_color = find_eater_eye_color
    fortune = @genes[[hair_color, eye_color]]
    eater.give_fortune(fortune)
    sleep 2.weeks
    eater.how_true?(fortune)
  end
end
```

In this not-at-all-contrived example, ```Evolvable.combine_dimensions([HAIR_COLOR, EYE_COLORS])``` returns

```ruby
[["auburn", "blue"], ["auburn", "brown"], ["auburn", "gray"], ["auburn", "green"], ["black", "blue"], ["black", "brown"], ["black", "gray"], ["black", "green"], ["blond", "blue"], ["blond", "brown"], ["blond", "gray"], ["blond", "green"], ["brown", "blue"], ["brown", "brown"], ["brown", "gray"], ["brown", "green"], ["gray", "blue"], ["gray", "brown"], ["gray", "gray"], ["gray", "green"], ["red", "blue"], ["red", "brown"], ["red", "gray"], ["red", "green"], ["white", "blue"], ["white", "brown"], ["white", "gray"], ["white", "green"]]
```

which is useful for composing genes made up of various dimensions and accessing gene values by these dimensions in the ```#fitness``` and ```.evolvable_evaluate!(objects)``` methods.

The ```Evolvable.combine_dimensions(dimensions)``` method accepts an array containing any number of arrays as an argument. One item from each given array will be in each output array and the item's index will be the same as the index of the argument array it belongs to. All combinations of items from the various arrays that follow this rule will be returned as arrays. The number of output arrays is equal to the product of multiplying the sizes of each given array. This method was difficult to write as was this description. I'd be really interested to see other people's implementations :)

### Configuration

TODO: Make logger configurable and make it smarter about picking a default

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

If you see a TODO in this README, feel free to do it :)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/evolvable.
