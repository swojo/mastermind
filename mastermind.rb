class GameStatus
  attr_reader :code, :num_of_tries
  def initialize(code)
    @code = code
    @num_of_tries = 0
  end
  
  def win?(guess)
    @code == guess
  end

  def valid_letters
    %w{R G O Y B P}
  end

  def process_guess(guess)
    @num_of_tries += 1
    if win?(guess) 
      Solution.new(guess, @num_of_tries)
    else
      result_hash = CodeComparer.new(@code, guess).compare
      IncorrectGuess.new(result_hash, guess, @num_of_tries)
    end
  end
end

class IncorrectGuess
  attr_reader :result_hash
  attr_reader :num_of_tries, :guess 
 
  def initialize(hash, guess, num_of_tries)
    @result_hash = hash
    @guess = guess
    @num_of_tries = num_of_tries
  end

  def correct?
    false
  end
end

class Solution
  attr_reader :num_of_tries, :guess

  def initialize(guess, num_of_tries)
    @guess = guess
    @num_of_tries = num_of_tries
  end

  def correct?  
    true
  end
end

class CodeComparer
  def initialize(code, guess)
    @code = code
    @guess = guess
  end

  def correct_positions 
    code_with_indeces = @code.each_with_index.to_a
    guess_with_indeces = @guess.each_with_index.to_a
    intersection = code_with_indeces & guess_with_indeces
    intersection.size
  end

  def total_correct_colors 
    correct_color = 0
    @code.uniq.each do |letter|
      correct_color += [@code.count(letter), @guess.count(letter)].min
    end
    correct_color
  end
  
  def compare
    correct_colors = total_correct_colors - correct_positions
    {
      correct_positions: correct_positions, 
      correct_colors: correct_colors
    }
  end
end

class NaiveAlgorithm
  attr_accessor :possible_guesses

  def initialize(valid_letters)
    @valid_letters = valid_letters
    @possible_guesses = valid_letters.repeated_permutation(4).to_a
  end
  
  def next_guess
    @possible_guesses[0]
  end

  def discard_invalid_guesses(incorrect_guess)
    discarded_guesses = @possible_guesses.select do |guess|
      compare_result = CodeComparer.new(incorrect_guess.guess, guess).compare
      compare_result != incorrect_guess.result_hash
    end
    @possible_guesses -= discarded_guesses
  end
end

class AIPlayer
  def initialize(board)
    @board = board
    @valid_letters = @board.valid_letters
    @algorithm = NaiveAlgorithm.new(@valid_letters)
  end
 
  def solve
    next_guess = @algorithm.next_guess
    result = @board.process_guess(next_guess)
    return result if result.correct? || result.num_of_tries == 10
    
    @algorithm.discard_invalid_guesses(result)
    solve
  end
end

class Terminal
  def display(message)
    puts message 
  end 

  def formatted_input(stdin = $stdin)
     stdin.gets.upcase.split(%r{\s*} )
  end
end

class Validator
  def initialize(code)
    @code = code
    @code_length = 4
    @valid_letters = %w{R G O Y B P}
  end
 
  def correct_length?
    @code.size == @code_length
  end

  def valid_letters?
    @code.uniq.all? do |letter|
      @valid_letters.include?letter
    end
  end
  
  def valid?
    correct_length? && valid_letters?
  end  
end

class GameText 
  def message(message_type, game_result = {})
   case message_type
    when :welcome
      "Welcome To Mastermind"
    when :prompt
      "Please Enter the Code: "
    when :win
      "You win!"
    when :lose
      "Haha! You lost!"
    else 
      "Come again?"
   end
 end
end

class NewGame
  def initialize
    @game_text = GameText.new
    @terminal = Terminal.new
  end
  
  def get_input
    @terminal.display( @game_text.message(:prompt) )
    input = @terminal.formatted_input
    unless Validator.new(input).valid? 
      get_input
    else
      input
    end
  end
  
  def set_up_board(code)
    @board = GameStatus.new(code)
  end

  def run_ai_player
    AIPlayer.new(@board).solve
  end

  def end_of_game(result)
    if(result.correct?)
      @terminal.display(@game_text.message(:win))
    else
      @terminal.display(@game_text.message(:lose))
    end
  end 

  def play_game
    @terminal.display(@game_text.message(:welcome))
    code = get_input
    set_up_board(code)
    result = run_ai_player
    end_of_game(result)
  end
end   

if __FILE__ == $0
  NewGame.new.play_game   
end
