require 'rspec'
require_relative 'mastermind'

include Mastermind

describe 'Mastermind' do
  WIN_HASH = {correct_positions: 4, correct_colors: 0}

  let(:code){ %w{R R R R} }
  let (:default_colors){ %w{R G O Y B P} }

  describe 'GameStatus' do
    let (:code){ %w{A B C D} }
    let (:incorrect_guess){ %w{A C B E} }
    let (:board){GameStatus.new(code)}

    it 'keeps track of the number of guesses' do
      expect(board.num_of_tries).to eq(0)
      board.process_guess(incorrect_guess)
      expect(board.num_of_tries).to eq(1)
    end
    
    it 'stores the correct code' do
      expect(board.code).to eq(code)
    end
    it 'stores the valid letters' do
      expect(board.valid_letters).to eq(default_colors)
    end

    it 'returns a CurrentResult after tries a guess'

    it 'returns an incorrect result when incorrect guess' do
      expect(board.process_guess(incorrect_guess).correct?).to eq(false)
    end

    it 'returns a correct result when correct guess (win)' do
      expect(board.process_guess(code).correct?).to eq(true)
    end

    #is it ok that win? is not tested here?
  end

  describe 'CurrentResult' do
    it 'returns correct when winning result hash' do
      correct_hash = {correct_positions: 4 , correct_colors:0}
      expect(CurrentResult.new(nil, nil, correct_hash).correct?).to eq(true)
    end

    it 'returns incorrect when incorrect guess' do
      incorrect_hash = {correct_positions: 1 , correct_colors:0}
      expect(CurrentResult.new(nil, nil, incorrect_hash).correct?).to eq(false)
    end

    it 'stores the hash, num_of_tries and guess'
  end

  describe 'CodeComparer' do
    let (:code){ %w{A B C D} }
    let (:incorrect_guess){ %w{A C B E} }
    let (:code_comparer){CodeComparer.new(code,incorrect_guess)}
#    it 'returns correct number of matching positions' do
#      expect(code_comparer.correct_positions).to eq(1)
#    end
#    
#    it 'returns correct number of total matching colors' do
#      expect(code_comparer.total_correct_colors).to eq(3)
#    end

    it 'returns a hash with number of positions/colors' do
      result_hash = {correct_positions: 1, correct_colors:2}
      expect(code_comparer.compare).to eq(result_hash)
    end
  end

  describe 'NaiveAlgorithm' do
    let (:naive_algorithm){NaiveAlgorithm.new(default_colors)}

    it 'initializes possible guesses to all permutations' do
      expect(naive_algorithm.possible_guesses.size).to eq(1296)
    end

    it 'chooses the next available guess' do
      expect(naive_algorithm.next_guess).to eq( %w{R R R R} )
    end

    it 'discards invalid guesses based on previous result' do
      result_hash = {correct_positions: 0, correct_colors: 0}
      guess = %w{R R R R}
      incorrect_guess = CurrentResult.new(guess, nil, result_hash )
      expect(naive_algorithm.next_guess).to eq( %w{R R R R} )
      naive_algorithm.discard_invalid_guesses(incorrect_guess)
      expect(naive_algorithm.next_guess).to eq( %w{G G G G} )
    end
  end

  describe 'AIPlayer' do
    let(:board){GameStatus.new(code)}
    let(:ai_player){AIPlayer.new(board)}
    let(:solution){CurrentResult.new(code, 1, WIN_HASH )}

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

    it 'gets a Solution from winning AIPlayer' do 
      new_game.set_up_board(%w{R R R R})
      expect(new_game.run_ai_player.correct?).to eq(true)
    end 
    it 'prints winning end message if win' do
      code = %w{R R R R}
      result = CurrentResult.new(code, 1, WIN_HASH)
      expect{new_game.end_of_game(result)}.to output("You win!\n").to_stdout
    end

    it 'prints losing end message if lose' do
      result = CurrentResult.new(nil, nil, nil)
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
end
