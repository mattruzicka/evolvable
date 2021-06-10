# frozen_string_literal: true

module Evolvable
  class Serializer
    class << self
      def dump(data)
        klass.dump(data)
      end

      def load(data)
        klass.load(data)
      end

      private

      def klass
        @klass ||= Marshal
      end
    end
  end
end
