require 'sudoku/grid'
require 'sudoku/notes_grid'
require 'sudoku/matrices'
require 'sudoku/refinements'

module Sudoku
  class Game
    @mutex   = Mutex.new
    @games   = {}
    @last_id = 0

    attr_reader :id, :grid, :notes_grid

    def initialize(id, grid_or_matrix, notes_grid = nil)
      @id   = id
      @grid = if grid_or_matrix.is_a?(Grid)
                grid_or_matrix
              else
                Grid.new(grid_or_matrix)
              end

      @notes_grid = notes_grid || NotesGrid.new
    end

    def fill_cell(row, column, number)
      with_grid(grid.fill_cell(row, column, number))
    end

    def add_note(row, column, number)
      raise Exceptions::CellAlreadyFilled.new(row, column) if self.grid.cell_filled?(row, column)

      with_notes_grid(self.notes_grid.add_note(row, column, number))
    end

    def finished?
      @grid.completely_filled?
    end

    private

    def with_grid(grid)
      self.class.new(id, grid, self.notes_grid)
    end

    def with_notes_grid(notes_grid)
      self.class.new(id, self.grid, notes_grid)
    end

    # TODO: move this into some GameStorage class, which will be part of app, not lib
    # - this will also make the game much simpler and similar to client-side implementation
    # - ideally we should have sudoku-common where this can live and be shared btw client and server
    class << self
      def with(grid_or_matrix)
        id   = next_id
        game = Game.new(id, grid_or_matrix)

        @games[id] = game

        game
      end

      def generate
        with(Matrices::ALMOST_FINISHED_MATRIX)
      end

      def get(game_id)
        @games[game_id]
      end

      def set(game_id, game)
        @games[game_id] = game
      end

      def all_ids
        @games.keys
      end

      private

      def next_id
        @mutex.synchronize { @last_id += 1 }
      end
    end
  end
end
