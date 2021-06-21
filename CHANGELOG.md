## Unreleased

Features
* Genome abstraction for genes 69afd7c957cbf89cc03b4f3f0ba967bf571c34c5
* Built-in support for count genes 69afd7c957cbf89cc03b4f3f0ba967bf571c34c5
* Add serializer for dumping and loading for population and genogenome objects 9d2a42a29103e1525b3c5471578ee97baeb6e8c6
* Add the following delegation methods to Evolvable::Population ffb9998b09f02fa6759322c324b2f448fd3af223
* Keep previous generation parents for generating instances for the current generation whenever 856ac3a778106d34221ce8ce8ae14b963877dc76
* Add Evolvable::Population.new_instance and methods to Evolvable Selection, Crossover, and Mutation for acting on instances 856ac3a778106d34221ce8ce8ae14b963877dc76

```
selection_size
selection_size=
mutation_rate
mutation_rate=
mutation_probability
mutation_probability=
```

Changes
* Renamed Goal classes. The old, namespaced goal classes will be removed in version 2.0 a3fb1915230cc297e545d873a80f0324bca5833d
* Renamed Evolvable#population_index to generation_index. The The population_index method will be removed in version 2.0 e0251f7c51818c30986d5a9a2b44f3834107ec55
* Rename evolvable_class keyword arg in Evolvable::Population#initialize to evolvable_type and suport strings and classes as arguments. Passing evolvable_class is deprecated and will be removed in version 2.0 and at that time the evolvable_tyoe keyword arg will be required 1491f4b6f5bb615ae17e749922a852edce48072b
* Evolvable::Population.new_instance new uses the previous generation's parents to generate a new instance, if there is one. Otherwise, it continues to randomly intitialize the instances from the defined gene space.

## 1.0.2 - 2021-04-04

Features
* Make gene_key assignment a class level concern. Makes custom gene initialization simpler. https://github.com/mattruzicka/evolvable/pull/6

## 1.0.1

Bug fixes
* Fix goal normalization in `Evolvable::Evaluation` when given an object

## 1.0.0

Hello 🌎 🌍 🌏

Check out the [README](https://github.com/mattruzicka/evolvable/blob/master/README.md) for everything

___


🧬 🧬 🧬

Please [open an issue](https://github.com/mattruzicka/evolvable/issues/new) if you cannot find what you're looking for

🧬 🧬 🧬
