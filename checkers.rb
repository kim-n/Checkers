class InvalidMoveError < StandardError
end

class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8){ Array.new(8) {nil} }
    addpawns
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

  def piece_at(pos)
    @grid[pos[0]][pos[1]] unless @grid[pos[0]][pos[1]].nil?
  end

  def slide!(s_pos, e_pos)
    start_x, start_y = s_pos[0], s_pos[1]
    end_x, end_y = e_pos[0], e_pos[1]

    @grid[end_x][end_y] = @grid[start_x][start_y]
    @grid[end_x][end_y].position = e_pos
    @grid[start_x][start_y] = nil
  end

  def find_piece_to_remove(s_pos, e_pos)
    x = (s_pos[0] - e_pos[0])/2
    y = (s_pos[1] - e_pos[1])/2
    [e_pos[0] + x, e_pos[1] + y ]
  end

  def jump!(s_pos, e_pos)
    mid_piece = find_piece_to_remove(s_pos, e_pos)


    start_x, start_y = s_pos[0], s_pos[1]
    end_x, end_y = e_pos[0], e_pos[1]

    @grid[end_x][end_y] = @grid[start_x][start_y]
    @grid[end_x][end_y].position = e_pos
    @grid[start_x][start_y] = nil
    @grid[mid_piece[0]][mid_piece[1]] = nil

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

  def move!(s_pos, e_pos)
     start_x, start_y = s_pos[0], s_pos[1]
     end_x, end_y = e_pos[0], e_pos[1]

     #Removes stray pointers
     @grid[end_x][end_y].board = nil if !@grid[end_x][end_y].nil?

     @grid[end_x][end_y] = @grid[start_x][start_y]
     @grid[end_x][end_y].position = e_pos if !@grid[end_x][end_y].nil?
     @grid[start_x][start_y] = nil
   end

   # def perform_moves
   #   if move_sequence.size > 1
   #     begin
   #       perform_moves!(*move_sequence)
   #     #perform jump
   #   else
   #     #perform slide sequence
   #   end
   #
   #   # checks validmove_seq?
   #   # calls perform_moves! or raises InvalidMoveError
   # end



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
    unless self.king
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
    color.nil? ? piece_at_pos : (piece_at_pos && (piece_at_pos).color == color)  end


  def slide_moves
    offsets = self.offsets
    possible_moves = []

    offsets.each do |offset|
      dx, dy = @position[0] + offset[0], @position[1]+ offset[1]
      possible_moves << [dx, dy] if is_valid?([dx,dy]) && !occupied?([dx,dy])
    end
    possible_moves
  end

  def jump_moves
    offsets = self.offsets
    possible_moves = []

    offsets.each do |offset|
      dx, dy = @position[0], @position[1]
      dx2, dy2 = dx + offset[0], dy + offset[1] #next spot
      dx3, dy3 = dx2 + offset[0], dy2 + offset[1] #next next spot

      next if ( !is_valid?([dx3,dy3]) || occupied?([dx3,dy3]) ||  !occupied?([dx2,dy2]) || occupied?([dx2,dy2], @color) )
      possible_moves << [dx3,dy3]
    end
    possible_moves

  end


  def perform_slide(start_pos, end_pos)
    if @board.piece_at(start_pos).nil?
      raise InvalidMoveError, "Nothing at start position"
    elsif !self.slide_moves.include?(end_pos)
      raise InvalidMoveError, "Cant slide to that position"
    end

    @board.slide!(start_pos, end_pos)
    # validate the move
    # illegal slide should raise an InvalidMoveError.
  end


  def perform_jump(start_pos, end_pos)
    if @board.piece_at(start_pos).nil?
      raise InvalidMoveError, "Nothing at start"
    elsif !self.jump_moves.include?(end_pos)
      p self.jump_moves
      raise InvalidMoveError, "Can't jump to end"
    end

    @board.jump!(start_pos, end_pos)    # Perform jump
    #@board.jump!(@position, end_pos)
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




  def perform_moves!(*move_sequence)
    moves = move_sequence
    if moves.size > 1
      #perform jumps
      (moves.size-1).times do |t|
        perform_jump(moves[t], moves[t+1])
      end
    else

      #perform slide sequence
    end
    # that takes a sequence of moves
    # one slide or
    # one or more jumps.
    # should perform the moves one-by-one.
    # If move in sequence fails, raise InvalidMoveError
    # Do not restore original board state if move fails
  end


end

#________T_E_S_T_S_________#

game = Board.new

pawn = game.grid[2][0]

game.move!([5,1], [3,1])

game.print_board
pawn.king = true


puts
game.print_board

 begin
 pawn.perform_moves!(pawn.position, [4,2])

 #pawn.perform_jump(pawn.position, [4,2])
rescue InvalidMoveError => e
  puts e

end

puts
game.print_board
p pawn.jump_moves()
p pawn.slide_moves()
#
#
#  #game.move!([2,0], [4,2])
#  #
#  #game.move!([2,0], [6,4])
#
#  #pawn = game.grid[6][4]
#  pawn.king = true
#
#  # p "Slide from [2,0] to [4,2]"
#  # pawn.perform_slide(pawn.position, [4,2])
#  # game.print_board
#
#  puts
#  game.move!([6,4], [3,1])
#  # game.print_board
#
#  #
#  # puts
#  # p "Jump from [4,2] to [6,4]"
#  # pawn.perform_jump(pawn.position, [4,2])
#  # game.print_board
# #
#  begin
#  pawn.perform_moves!(pawn.position, [4,2], [6,4], [4,6])
#
#  #pawn.perform_jump(pawn.position, [4,2])
# rescue InvalidMoveError => e
#   puts e
#
# end
#
# puts
# game.print_board
#
# p pawn.jump_moves
# p pawn.slide_moves()
# # #p game.piece_at([1,1]).color
#  #pawn = game.grid[4][2]
#
#
# # p pawn.slide_moves()  # slidedoes not take care of nil
# # p pawn.jump_moves()