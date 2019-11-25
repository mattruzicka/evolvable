# frozen_string_literal: true

module Evolvable
  module Gene
    def self.included(base)
      def base.new_evolvable
        new
      end
    end

    attr_accessor :evolvable_key
  end
end
