class Board
  def initialize
    @grid = Array.new(6) { Array.new(7) { "-" } }
  end

  def drop_disc(column, disc)
    (0..5).to_a.reverse.each do |row|
      if @grid[row][column] == "-"
        @grid[row][column] = disc
        return
      end
    end
  end

  def remove_from(column)
    (0..5).to_a.each do |row|
      if @grid[row][column] != "-"
        @grid[row][column] = "-"
        return
      end
    end
  end

  def col_full?(column)
    @grid[0][column] != "-"
  end

  def over?
    !!winner || (0..6).all? { |col| col_full?(col) }
  end

  def winner
    vertical_victor || horizontal_victor || diagonal_victor
  end

  def four_in_a_row line
    line[0..3].uniq.size == 1 && line[0] != "-"
  end

  def vertical_victor
    @grid.transpose.each do |col|
      (0..2).each { |i| return col[i] if four_in_a_row(col[i..i+3]) }
    end
    false
  end

  def horizontal_victor
    @grid.each do |row|
      (0..3).each { |i| return row[i] if four_in_a_row(row[i..i+3]) }
    end
    false
  end

  def diagonal_victor
    diagonals.each { |diag| return diag[0] if four_in_a_row(diag) }
    false
  end

  def diagonals
    diagonals = []

    (3..5).each do |row_idx|
      (0..3).each do |col_idx|
        diagonals << step_up_side(row_idx, col_idx, 1)
        diagonals << step_up_side(row_idx, col_idx + 3, -1)
      end
    end

    diagonals
  end

  def step_up_side row, col, direction
    diag = []
    4.times { |i| diag << @grid[row - i][col + (i * direction)] }
    diag
  end

  def render
    @grid.each { |row| puts row.join(" ") }
  end

  def valid?(col)
    !col_full?(col) && (0..6).include?(col)
  end
end

class Game
  def initialize
    @board = Board.new
    set_up_players
    @current_player = 0
  end

  def switch_player
    @current_player = 1 - @current_player
  end

  def set_up_players
    player1 = HumanPlayer.new(:o)
    player2 = ComputerPlayer.new(:x, :o, @board)
    @players = [player1, player2]
  end

  def run
    puts "Welcome to Connect4!"

    until @board.over?
      puts "\n"
      @board.render
      col = -1
      col = @players[@current_player].make_guess until @board.valid?(col)
      @board.drop_disc(col, @players[@current_player].mark)
      switch_player
    end

    @board.render
    puts @board.winner ? "Congrats #{@board.winner}! You win." : "Tie game."
  end


end

class HumanPlayer
  attr_reader :mark

  def initialize(mark)
    @mark = mark
  end

  def make_guess
    puts "Please enter a column:"
    gets.chomp.to_i
  end
end

class ComputerPlayer
  attr_reader :mark

  def initialize(mark, other_mark, board)
    @mark = mark
    @board = board
    @other_mark = other_mark
  end

  def make_guess
    !!winning_move(mark) ? winning_move(mark) : best_available_move
  end

  def winning_move(mark, board = @board)
    test_board = board.dup
    (0..6).each do |col|
      if @board.valid?(col)
        test_board.drop_disc(col,mark)
        winning = !!test_board.winner
        test_board.remove_from(col)
        return col if winning
      end
    end
    return false
  end

  def best_available_move
    #will test all possible moves and reject ones which would
    #give the other player a winning move. From the remaining
    #moves, pick a random one
    new_board = @board.dup
    scores = Array.new(7, 0)
    (0..6).each do |comp_move|
      if @board.valid?(comp_move)
        new_board.drop_disc(comp_move, mark)
        if (0..6).any? { |move| winning_move(@other_mark, new_board) }
          scores[comp_move] = -1
        end
        new_board.remove_from(comp_move)
      else
        scores[comp_move] = -1000
      end
    end
    return rand(7) if scores.uniq.size == 1
    scores.index(scores.max)
  end
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.run
end
