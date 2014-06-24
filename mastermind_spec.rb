require 'rspec'
require_relative 'mastermind'

describe 'GameStatus' do
  let (:code){ %w{A B C D} }
  let (:incorrect_guess){ %w{A C B E} }
  let (:board){GameStatus.new(code)}
  let (:default_colors){ %w{R G O Y B P} }

  it 'keeps track of the number of guesses' do
    expect(board.num_of_tries).to eq(0)
    board.process_guess incorrect_guess
    expect(board.num_of_tries).to eq(1)
  end
  
  it 'stores the correct code' do
    expect(board.code).to eq(code)
  end
  it 'stores the valid letters' do
    expect(board.valid_letters).to eq(default_colors)
  end

  it 'checks if the guess is correct' do
    expect(board.win? code).to eq(true)
  end
 
  it 'detects when guess is incorrect' do
    expect(board.win? incorrect_guess).to eq(false)
  end

  it 'returns an IncorrectGuess when incorrect guess' do
    result_hash = {correct_positions: 1, correct_colors:2}
    expect((board.process_guess incorrect_guess).class).to eq(IncorrectGuess.new(result_hash, nil, nil).class) 
  end

  it 'returns a Solution when correct guess' do
    expect((board.process_guess code).class).to eq(Solution.new(code,1).class)
  end
end

describe 'Test' do
  let (:code){ %w{R R R R} }
  let (:board){GameStatus.new(code) }
  
  it 'returns a Solution when correct guess' do
    expect((board.process_guess code).class).to eq(Solution.new(nil, 0).class)
    expect(board.process_guess(code).correct?).to eq(true)
  end

end

describe 'IncorrectGuess' do
  result_hash = {correct_positions: 1, correct_colors:2}
  let (:incorrect_guess){IncorrectGuess.new(result_hash, nil, nil)}

  it 'returns incorrect' do
    expect(incorrect_guess.correct?).to eq(false)
  end

  it 'contains the result hash' do
    expect(incorrect_guess.result_hash).to eq(result_hash)
  end
end

describe 'Solution' do
  let (:num_of_tries){2}
  let(:guess){ %w{R R R R} }
  let (:solution){Solution.new(guess, num_of_tries)}

  it 'returns correct' do
    expect(solution.correct?).to eq(true)
  end

  it 'contains the number of tries' do
    expect(solution.num_of_tries).to eq(num_of_tries)
  end
end

describe 'CodeComparer' do
  let (:code){ %w{A B C D} }
  let (:incorrect_guess){ %w{A C B E} }
  let (:code_comparer){CodeComparer.new(code,incorrect_guess)}
  it 'returns correct number of matching positions' do
    expect(code_comparer.correct_positions).to eq(1)
  end
  
  it 'returns correct number of total matching colors' do
    expect(code_comparer.total_correct_colors).to eq(3)
  end

  it 'returns a hash with number of positions/colors' do
    result_hash = {correct_positions: 1, correct_colors:2}
    expect(code_comparer.compare).to eq(result_hash)
  end
end

describe 'NaiveAlgorithm' do
  let (:valid_letters){ %w{R G O Y B P} }
  let (:naive_algorithm){NaiveAlgorithm.new(valid_letters)}

  it 'initializes possible guesses to all permutations' do
    expect(naive_algorithm.possible_guesses.size).to eq(1296)
  end

  it 'chooses the next available guess' do
    expect(naive_algorithm.next_guess).to eq( %w{R R R R} )
  end

  it 'discards invalid guesses based on previous result' do
    result_hash = {correct_positions: 0, correct_colors: 0}
    guess = %w{R R R R}
    incorrect_guess = IncorrectGuess.new(result_hash, guess, nil )
    expect(naive_algorithm.next_guess).to eq( %w{R R R R} )
    naive_algorithm.discard_invalid_guesses(incorrect_guess)
    expect(naive_algorithm.next_guess).to eq( %w{G G G G} )
#    naive_algorithm.discard_invalid_guesses
  end
end

describe 'AIPlayer' do
  let(:code){ %w{R R R R} }
  let(:board){GameStatus.new(code)}
  let(:ai_player){AIPlayer.new(board)}
  let(:solution){Solution.new(code, 1)}

  it 'calls process_guess once if wins on first try' do
    expect(board).to receive(:process_guess).with(code).and_return(solution)
    ai_player.solve
  end
  
  it 'returns the correct code when wins' do
    expect(ai_player.solve.guess).to eq(code)
  end

  it 'calls process_guess at most 10 times' do
    expect(board).to receive(:process_guess).at_most(10).times
  end
end   

describe 'GameText' do
  let(:game_text){GameText.new}

  it 'displays welcome message' do
    expect(game_text.message(:welcome)).to eq("Welcome To Mastermind")
  end

  it 'prompts user for input' do
    expect(game_text.message(:prompt)).to eq("Please Enter the Code: ")
  end

  it 'displays winning message' do
    expect(game_text.message(:win)).to eq("You win!")
  end
  
  it 'displays losing message' do
    expect(game_text.message(:lose)).to eq("Haha! You lost!")
  end
end
  

describe 'NewGame' do 
  let(:new_game){ NewGame.new }

  it 'returns input when valid' do
    terminal_obj = double('terminal_obj')
    allow(Terminal).to receive(:new){terminal_obj}
    expect(terminal_obj).to receive(:formatted_input).once.ordered.and_return(%w{R R R R} )
    expect(terminal_obj).to receive(:display)

    result = new_game.get_input
    expect(Validator.new(result).valid?).to eq(true)
  end

  it 'calls the function until valid' do
    terminal_obj = double('terminal_obj').as_null_object
    allow(Terminal).to receive(:new){terminal_obj}
    expect(terminal_obj).to receive(:formatted_input).once.ordered.and_return(%w{Z Z Z Z} )
    expect(terminal_obj).to receive(:formatted_input).once.ordered.and_return(%w{R R R R} )
    expect(terminal_obj).to receive(:display)

    result = new_game.get_input
    expect(Validator.new(result).valid?).to eq(true)
  end 

  it 'sets up board with new code' do
    code = %w{R R R R}
    expect(new_game.set_up_board(code).class.name).to eq("GameStatus")
  end

  it 'gets a Solution from winning AIPlayer' do 
    new_game.set_up_board(%w{R R R R})
    expect(new_game.run_ai_player.class.name).to eq("Solution")
  end 
  it 'prints winning end message if win' do
    code = %w{R R R R}
    result = Solution.new(code, 1)
    expect{new_game.end_of_game(result)}.to output("You win!\n").to_stdout
  end

  it 'prints losing end message if lose' do
    result = IncorrectGuess.new(nil, nil, nil)
    new_game.set_up_board(%w{R R R R})
    expect{new_game.end_of_game(result)}.to output("Haha! You lost!\n").to_stdout
  end

  it 'runs through the game' do
    expect_any_instance_of(GameText).to receive(:message).with(:welcome)
    expect(new_game).to receive(:get_input).and_return(%w{R O Y B} )
    expect_any_instance_of(GameText).to receive(:message).with(:win)
    new_game.play_game
  end 
end

describe 'Terminal' do
  let(:terminal){Terminal.new}

  it 'displays message' do
    expect{terminal.display('test message')}.to output("test message\n").to_stdout
  end

  it 'returns array of input letters' do
    uppercase_input = StringIO.new("ABCD\n")
    expect(terminal.formatted_input(uppercase_input)).to eq( %w{A B C D} )
  end

  it 'converts input to uppercase' do
    lowercase_input = StringIO.new("abcd\n") 
    expect(terminal.formatted_input(lowercase_input)).to eq(%w{A B C D})
  end

  it 'ignores whitespace' do
    whitespace_input = StringIO.new("a  b c  d\n")
    expect(terminal.formatted_input(whitespace_input)).to eq(%w{A B C D})
  end 
end

describe 'Validator' do
  let(:code){ %w{R R R R} }

  it 'accepts a 4 letter long code' do
    validator= Validator.new(code)
    expect(validator.correct_length?).to eq(true)
  end
  
  it 'detects incorrect code length' do
    validator = Validator.new( %w{R R R R R R} )
    expect(validator.correct_length?).to eq(false)
  end

  it 'accepts code made up of valid letters' do
    validator = Validator.new( %w{R R R R} )
    expect(validator.valid_letters?).to eq(true)
  end

  it 'detects invalid letters' do
    validator = Validator.new( %w{R Z R R} )
    expect(validator.valid_letters?).to eq(false)  
  end

  it 'fails if either letters or code length are incorrect' do
    wrong_length = Validator.new( %w{R R R R R R})
    expect(wrong_length.valid?).to eq(false)

    wrong_letters = Validator.new( %w{R X R R} )
    expect(wrong_letters.valid?).to eq(false) 

    correct_validator = Validator.new( %w{R G O Y} )
    expect(correct_validator.valid?).to eq(true)
  end
end

