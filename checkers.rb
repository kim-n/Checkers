class InvalidMoveEror < StandardError
end

class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8){ Array.new(8) {nil} }
    addpawns
  end

  def piece_at(pos)
    @grid[pos[0]][pos[1]]
  end

  def print_board
    8.times do |i|
      8.times do |j|
        if @grid[i][j].is_a?(Pawn)
          print "#{@grid[i][j].color} "
        else
          print "- "
        end
      end
      print "\n"
    end
  end

  def addpawns
    8.times do |row|
      color = row < 4 ? :w : :b
      8.times do |col|
        if (row + col) % 2 == 0
          if [0,2,6].include?(row)
            @grid[row][col] = Pawn.new(color, self, [row, col])
          elsif [1,5,7].include?(row)
            @grid[row][col] = Pawn.new(color, self, [row, col])
          end
        end
      end
    end
  end

end  #END BOARD

class Pawn
  attr_accessor :color, :board, :position, :king

  Diagonals = [
    [1, -1],
    [1, 1],
    [-1,-1],
    [-1, 1]
  ]

  def initialize(color, board, position, king = false)
    @position = position
    @color = color
    @board = board
    @king = king
  end

  def offsets
    offsets = []
    if self.king != true
      if self.color == :w
        offsets = Diagonals[0..1]
      else
        offsets = Diagonals[2..3]
      end
    else
      offsets = Diagonals
    end
    offsets
  end


  def is_valid?(pos)
    pos.all? {|d| d.between?(0,7)}
  end

  def occupied?(pos,color = nil)
    piece_at_pos = board.piece_at(pos)  # nil if there is no piece there
    if color.nil?
      piece_at_pos
    else
      piece_at_pos && (piece_at_pos).color == color
    end
  end

  def king_moves
    possible_moves = []
    offsets.each do |offset|
      dx, dy = @position[0] + offset[0], @position[1]+ offset[1]
      while is_valid?([dx,dy])
        if !occupied?([dx,dy])
          possible_moves << [dx, dy]
          dx, dy = dx + offset[0], dy + offset[1]
        elsif occupied?([dx,dy], @color) #occupied by me
          break
        else  #occupied by next color
          #check that position after is empty
          dx, dy = dx + offset[0], dy + offset[1]
          if occupied?([dx,dy]) # by anyone
            break
          else  #blank spot
            possible_moves << [dx,dy]
            dx, dy = dx + offset[0], dy + offset[1]
          end
        end
      end
    end
    possible_moves
  end

  def pawn_moves
    possible_moves = []
    offsets.each do |offset|
      dx, dy = @position[0] + offset[0], @position[1]+ offset[1]
      possible_moves << [dx,dy] if is_valid?([dx,dy])
    end

    possible_moves
  end

  def slide_moves
    offsets = self.offsets

    self.king == true ? king_moves : pawn_moves
  end

  def jump_moves

  end

  def perform_slide
    # validate the move
    # illegal slide should raise an InvalidMoveError.
  end

  def perform_jump
    # validate the move
    # remove the jumped piece from the
    # illegal jump should raise an InvalidMoveError.
  end

  def validmove_seq?
    # calls perform_moves! on a duped Piece/Board
    # should not modify original board
    # If no error is raised return true else false.
    #
  end

  def perform_moves
    # checks validmove_seq?
    # calls perform_moves! or raises InvalidMoveError
  end

  def perform_moves!(move_sequence)
    # that takes a sequence of moves
    # one slide or
    # one or more jumps.
    # should perform the moves one-by-one.
    # If move in sequence fails, raise InvalidMoveError
    # Do not restore original board state if move fails
  end


end

game = Board.new
game.print_board
pawn = game.grid[1][3]
p pawn.slide_moves()
pawn.king = true
p pawn.slide_moves()