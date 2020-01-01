# shamelessly stolen from https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/object/inclusion.rb

module Sudoku
  module Inclusion
    refine Object do
      def in?(another_object)
        another_object.include?(self)
      rescue NoMethodError
        raise ArgumentError, 'The parameter passed to #in? must respond to #include?'
      end
    end
  end

  module Duplication
    refine Object do
      def deep_dup
        duplicable? ? dup : self
      end

      def duplicable?
        true
      end
    end

    refine Array do
      def deep_dup
        map(&:deep_dup)
      end
    end

    refine Hash do
      def deep_dup
        hash = dup

        each_pair do |key, value|
          if key.frozen? && key.is_a?(String)
            hash[key] = value.deep_dup
          else
            hash.delete(key)
            hash[key.deep_dup] = value.deep_dup
          end
        end

        hash
      end
    end

    refine Method do
      def duplicable?
        false
      end
    end

    refine UnboundMethod do
      def duplicable?
        false
      end
    end
  end
end
