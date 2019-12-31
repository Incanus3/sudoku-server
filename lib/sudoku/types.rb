require 'dry-types'

module Sudoku
  module Types
    include Dry.Types()

    OneToNine = Types::Integer.constrained(gteq: 1, lteq: 9)
  end
end
