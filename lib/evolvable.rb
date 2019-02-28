# frozen_string_literal: true

require 'forwardable'
require 'evolvable/version'
require 'evolvable/population'
require 'evolvable/crossover'
require 'evolvable/mutation'
require 'evolvable/helper_methods'
require 'evolvable/errors/not_implemented'

# TODO: make genes an array (not hash) - mutation and crossover functions will benefit
# Make each gene an object that has its own encode, select, etc function
# Make gene lookup fast (binary search?)

module Evolvable
  extend HelperMethods

  def self.included(base)
    def base.evolvable_gene_pool
      # TODO: add message about what the gene pool is
      raise Errors::NotImplemented, __method__
    end

    def base.evolvable_evaluate!(_individuals)
      # TODO: add message that says to assign fitness to each individual
      raise Errors::NotImplemented, __method__
    end

    def base.evolvable_initialize(_genes, _generation, _index)
      # TODO: add message about what the individual needs (genes)/fitness
      raise Errors::NotImplemented, __method__
    end

    def base.evolvable_genes_count
      evolvable_gene_pool.count
    end
  end

  def fitness
    # TODO: add message about fitness
    raise Errors::NotImplemented, __method__
  end

  def genes
    # TODO: add message about fitness
    raise Errors::NotImplemented, __method__
  end
end
