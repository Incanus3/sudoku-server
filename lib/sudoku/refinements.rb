module Sudoku
  module ObjectRefinements
    refine Object do
      # shamelessly stolen from https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/object/inclusion.rb
      def in?(another_object)
        another_object.include?(self)
      rescue NoMethodError
        raise ArgumentError, 'The parameter passed to #in? must respond to #include?'
      end
    end
  end
end
