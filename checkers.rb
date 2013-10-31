class InvalidMoveEror < StandardError
end

class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8){ Array.new(8) {nil} }
    addpawns
  end

  def piece_at(pos)
    @grid[pos[0]][pos[1]] unless @grid[pos[0]][pos[1]].nil?
  end

  def move!(s_pos, e_pos)
    start_x, start_y = s_pos[0], s_pos[1]
    end_x, end_y = e_pos[0], e_pos[1]

    #Removes stray pointers
    @grid[end_x][end_y].board = nil if !@grid[end_x][end_y].nil?

    @grid[end_x][end_y] = @grid[start_x][start_y]
    @grid[end_x][end_y].position = e_pos if !@grid[end_x][end_y].nil?
    @grid[start_x][start_y] = nil
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
      self.color == :w ? offsets = Diagonals[0..1] : offsets = Diagonals[2..3]
    else
      offsets = Diagonals
    end
    offsets
  end


  def is_valid?(pos)
    pos.all? {|d| d.between?(0,7)}
  end

  def occupied?(pos,color = nil)
    piece_at_pos = @board.piece_at(pos)  # nil if there is no piece there
    if color.nil?
      piece_at_pos
    elsif !piece_at_pos.nil?
      piece_at_pos && (piece_at_pos).color == color
    else
      nil
    end

  end


  def pawn_jump_moves
    possible_moves = []
    offsets.each do |offset|
      dx, dy = @position[0] + offset[0], @position[1]+ offset[1]
      if is_valid?([dx,dy]) && occupied?([dx,dy])
        possible_moves += [dx,dy] if !occupied?([dx+offset[0],dy+ offset[1]])
      end
    end

    possible_moves


    # elsif occupied?([dx,dy], @color) #occupied by me
    #   break
    # else  #occupied by next color
    #   #check that position after is empty
    #   dx, dy = dx + offset[0], dy + offset[1]
    #   next unless is_valid?([dx,dy])
    #   if occupied?([dx,dy]) # by anyone
    #     break
    #   else  #blank spot
    #     possible_moves << [dx,dy]
    #     dx, dy = dx + offset[0], dy + offset[1]
    #   end
    # end
  end


  def slide_moves
    offsets = self.offsets
    possible_moves = []

    offsets.each do |offset|
      dx, dy = @position[0] + offset[0], @position[1]+ offset[1]
      while is_valid?([dx,dy])
        break if occupied?([dx,dy])
        possible_moves << [dx, dy]
        break if @king == false
        dx, dy = dx + offset[0], dy + offset[1]
      end
    end
    possible_moves
  end

  def jump_moves
    offsets = self.offsets
    possible_moves = []

    jump_sequence(@position)
  end

  def jump_sequence(pos)
    offsets = self.offsets

    possible_moves = {}

    offsets.each do |offset|
      dx, dy = pos[0], pos[1]
      moves = Hash.new{[]}

      while(is_valid?([dx,dy]))
        dx2, dy2 = dx + offset[0], dy + offset[1] #next spot
        dx3, dy3 = dx2 + offset[0], dy2 + offset[1] #next next spot

        break if ( !is_valid?([dx3,dy3]) || occupied?([dx3,dy3]) ||   occupied?([dx2,dy2], @color) )
        moves[[dx,dy]] += [[dx3,dy3]]
        dx, dy = dx3 , dy3
        # jump_sequence([dx,dy]) if @king == true
      end
      possible_moves.merge!(moves){|key, oldval, newval| newval + oldval}
    end
    possible_moves
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
pawn = game.grid[2][0]
p pawn.slide_moves()


pawn.king = true

 #game.move!([2,0], [4,2])
 game.move!([6,4], [3,1])
 game.move!([2,0], [6,4])

 pawn = game.grid[6][4]
 game.print_board

# #p game.piece_at([1,1]).color
 #pawn = game.grid[4][2]


 pawn.slide_moves()  # slidedoes not take care of nil
p pawn.jump_moves()