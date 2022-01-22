## 1.2.0 - 2022-1-22

* Make it easier to dump and load genomes and use custom serializers. [69afd7c](https://github.com/mattruzicka/evolvable/commit/69afd7c957cbf89cc03b4f3f0ba967bf571c34c5)
* Avoid needing Gene#combine implementations to deal with nil args. Technically this could be a breaking change if you have custom combination logic for when two evolvables have different numbers of the same kind of gene and you do something other than just return the gene that isn't nil, but that this is the case seems unlikely, especially considering I'm not even aware of anyone else using this gem in the wild. If you do, please reach out! I'd love to hear from you, even if you're angry about this! [7ae1087](https://github.com/mattruzicka/evolvable/commit/7ae108762505230d81afc79b2f6c3e679fadc1a4)


## 1.1.0 - 2021-12-30

Features
* Updated documentation.
* Genome abstraction for genes. [69afd7c](https://github.com/mattruzicka/evolvable/commit/69afd7c957cbf89cc03b4f3f0ba967bf571c34c5)
* Built-in support for count genes. [69afd7c](https://github.com/mattruzicka/evolvable/commit/69afd7c957cbf89cc03b4f3f0ba967bf571c34c5)
* Add serializer for dumping and loading for population and genogenome objects [9d2a42a](https://github.com/mattruzicka/evolvable/commit/9d2a42a29103e1525b3c5471578ee97baeb6e8c6)
* Keep previous generation parents for generating evolvables for the current generation whenever [856ac3a](https://github.com/mattruzicka/evolvable/commit/856ac3a778106d34221ce8ce8ae14b963877dc76)
* Add #new_evolvables methods to Evolvable Selection, Crossover, and Mutation for acting on evolvables [856ac3a](https://github.com/mattruzicka/evolvable/commit/856ac3a778106d34221ce8ce8ae14b963877dc76)
* Add EvolvablePopulation#reset_evolvables [b61cccb](https://github.com/mattruzicka/evolvable/commit/b61cccbee8ac8cc9f00496e5461131bb796af974)
* Improve gene class lookup. Suppose you have an evolvable Dog class with a Dog::TailGene class. Now you can just pass 'TailGene' as the 'type' in your gene space definition [079dcef](https://github.com/mattruzicka/evolvable/commit/079dcef000e57553db8c6e5b89207d2d8e5c9890)
* Allow Evolvable.search_space to return a hash, array (when only one gene type), or array of arrays [be56c9c](https://github.com/mattruzicka/evolvable/commit/be56c9cc73c7202abc4588cb20c340d1e49498ed)
* Add Evolvable.search_spaces method which can be defined instead of or in addition to Evolvable.search_space, as an array of search space definitions (configs or Evolvable::SearchSpace objects) [a3c3896](https://github.com/mattruzicka/evolvable/commit/a3c3896d8b1799b7fac6143812a5ef630f716d85)
* Add ability to inititalize evaluation, selection, combination, and mutation objects with a hash of parameters or object. [7c8fd58](https://github.com/mattruzicka/evolvable/commit/7c8fd586ec882f35e5ce35c5bc6a28982e4d0640)
* Add the following delegated methods to Evolvable::Population to change the default evolutionary parameters [ffb9998](https://github.com/mattruzicka/evolvable/commit/ffb9998b09f02fa6759322c324b2f448fd3af223)

```
selection_size
selection_size=
mutation_rate
mutation_rate=
mutation_probability
mutation_probability=
```


Changes
* Renamed Goal classes. The old, namespaced goal classes will be removed in version 2.0 [a3fb191](https://github.com/mattruzicka/evolvable/commit/a3fb1915230cc297e545d873a80f0324bca5833d)
* Renamed Evolvable#population_index to generation_index. The The population_index method will be removed in version 2.0 [e0251f7](https://github.com/mattruzicka/evolvable/commit/e0251f7c51818c30986d5a9a2b44f3834107ec55)
* Renamed evolvable_class keyword arg in Evolvable::Population#initialize to evolvable_type and suport strings and classes as arguments. Passing evolvable_class is deprecated and will be removed in version 2.0 and at that time the evolvable_tyoe keyword arg will be required [1491f4b](https://github.com/mattruzicka/evolvable/commit/1491f4b6f5bb615ae17e749922a852edce48072b)
* Renamed Evolvable::Population#new_instance to #new_evolvable + use the previous generation's parents to generate a new instance, if there is one. Otherwise, it continues to randomly intitialize the instances from the defined gene space.
* Renamed Evolvable#new_instance to #new_evolvable, .initialize_instance to .initialize_evolvable, and #initialize_instance to #after_initialize.
* Renamed "instance" and "instances" to "evolvable" and "evolvables" across the code base and API.
* Renamed Evolvable::GeneSpace to Evolvable::SearchSpace. Using Evolvable::GeneSpace and Evolvable.gene_space is deprecated and support will be removed in version 2.0 [837322a](https://github.com/mattruzicka/evolvable/commit/837322a66c87d6b3fdf992c1b6c7e1b2fb920fe7)
* Renamed Evolution#crossover to Evolution#combination. Using Evolution#crossover is deprecated and support will be removed in version 2.0 [7fad505](https://github.com/mattruzicka/evolvable/commit/7fad505a6dbc679412d5c0565d64791a6edad6b7)
* Renamed Population#crossover, crossover= to combination [d2190c5](https://github.com/mattruzicka/evolvable/commit/d2190c5b32584a95e25c40a30b685e634a1b6b7f)
* Renamed Gene.crossover to Gene.combine. Gene.crossover is deprecated and support will be removedin version 2.0 [ed2190c5](https://github.com/mattruzicka/evolvable/commit/ed2190c5b32584a95e25c40a30b685e634a1b6b7f)


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
