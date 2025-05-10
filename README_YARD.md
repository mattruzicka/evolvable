# Evolvable 🧬

[![Gem Version](https://badge.fury.io/rb/evolvable.svg)](https://badge.fury.io/rb/evolvable)

**Code Version: {@string Evolvable::VERSION}**

Evolvable is a Ruby gem that brings genetic algorithms to Ruby objects through simple, flexible APIs. Define genes, implement fitness criteria, and let evolution discover optimal solutions through selection, combination, and mutation.

Perfect for optimization problems, creative content generation, machine learning, and simulating complex systems.

## Why Evolvable?

Evolvable is ideal when the solution space is too large or complex for brute-force methods. Instead of hardcoding solutions, you define constraints and let evolution discover optimal configurations over time.

**The Evolvable Approach:**
- Explore vast solution spaces efficiently without examining every possibility
- Discover novel solutions that might not be obvious to human designers
- Adapt to changing conditions through continuous evolution
- Balance diverse objectives with communities of different populations
- Integrate evolutionary concepts directly into your Ruby object model
- Generate creative content like music, art, and text, not just numerical optimization

Whether you're optimizing parameters, generating creative content, or simulating complex systems, Evolvable provides a natural, object-oriented approach to evolutionary algorithms.

**Creative Applications**

Evolvable treats creative, object-oriented representations as first-class citizens. The same API that optimizes numeric parameters can evolve music compositions, UI layouts, or game content with equal fluency. Examples include:

- **Generative art**: Evolve visual compositions based on aesthetic criteria
- **Music composition**: Create melodies, chord progressions, and rhythms
- **Game design**: Generate levels, characters, or game mechanics
- **Natural language**: Evolve text with specific tones, styles, or constraints
- **UI/UX design**: Discover intuitive layouts and color schemes

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
* [Gene Clusters](#gene-clusters)
* [Community](#community)
* [Serialization](#serialization)
* [Documentation]({@string Evolvable::DOC_URL})


## Installation

Add [gem "evolvable"](https://rubygems.org/gems/evolvable) to your Gemfile and run `bundle install` or install it yourself with: `gem install evolvable`

**Ruby Compatibility:** Evolvable officially supports Ruby 3.0 and higher.

## Getting Started

{@readme Evolvable}

## Concepts

Evolvable is built on these core concepts:
- **Genes**: Ruby objects that represent traits or behaviors and are passed down during evolution.
- **Evolvables**: Your Ruby classes that include "Evolvable" and delegate to genes
- **Populations**: Groups of evolvables instances that evolve together
- **Evaluation**: Sorts evolvables by fitness
- **Evolution**: Selection → Combination → Mutation to generate new evolvables
- **Communities**: Encapsulate evolvable populations

The framework offers built-in implementations while allowing domain-specific customization through its extensible and swapable components.

## Genes

{@readme Evolvable::Gene}

[Gene Documentation]({@string Evolvable::DOC_URL}/Evolvable/Gene)

## Populations

{@readme Evolvable::Population}

[Population Documentation]({@string Evolvable::DOC_URL}/Evolvable/Population)

## Evaluation

{@readme Evolvable::Evaluation}

{@readme Evolvable::Goal}

Example goal implementation that prioritizes evolvables with fitness values within a specific range:

{@example Evolvable::Goal}

[Evaluation Documentation]({@string Evolvable::DOC_URL}/Evolvable/Evaluation)

[Goal Documentation]({@string Evolvable::DOC_URL}/Evolvable/Goal)

## Evolution

{@readme Evolvable::Evolution}

[Evolution Documentation]({@string Evolvable::DOC_URL}/Evolvable/Evolution)

## Selection

{@readme Evolvable::Selection}

[Selection Documentation]({@string Evolvable::DOC_URL}/Evolvable/Selection)

## Combination

{@readme Evolvable::GeneCombination}

[Combination Documentation]({@string Evolvable::DOC_URL}/Evolvable/Combination)

**Point Crossover**

{@readme Evolvable::PointCrossover}

[PointCrossover Documentation]({@string Evolvable::DOC_URL}/Evolvable/PointCrossover)

**Uniform Crossover**

{@readme Evolvable::UniformCrossover}

[UniformCrossover Documentation]({@string Evolvable::DOC_URL}/Evolvable/UniformCrossover)

## Mutation

{@readme Evolvable::Mutation}

[Mutation Documentation]({@string Evolvable::DOC_URL}/Evolvable/Mutation)

## Gene Clusters

{@readme Evolvable::GeneCluster}

[GeneCluster Documentation]({@string Evolvable::DOC_URL}/Evolvable/GeneCluster)

## Community

{@readme Evolvable::Community}

[Community Documentation]({@string Evolvable::DOC_URL}/Evolvable/Community)

## Serialization

{@readme Evolvable::Serializer}

[Serializer Documentation]({@string Evolvable::DOC_URL}/Evolvable/Serializer)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mattruzicka/evolvable.