require 'rspec'
require_relative '../lib/mastermind_cmdline'
require_relative '../lib/mastermind_cmdline/AIsolver'
require_relative '../lib/mastermind_cmdline/GameRules'
require_relative '../lib/mastermind_cmdline/GameStatus'
require_relative '../lib/mastermind_cmdline/TerminalInterface'

include Mastermind

DEFAULT_COLORS = %w{R G O Y B P}

describe 'Mastermind' do
  WIN_HASH = {correct_positions: 4, correct_colors: 0}

  let(:code){ %w{R R R R} }
  let (:default_colors){ %w{R G O Y B P} }

  describe 'GameStatus' do
    let (:code){ %w{A B C D} }
    let (:incorrect_guess){ %w{A C B E} }
    let (:board){GameStatus.new(code, DEFAULT_COLORS)}

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
    
    it 'detects the end of game on a win' do
      result = CurrentResult.new(code, nil, nil)
      expect(board.end_of_game?(result)).to eq(true)
    end

    it 'detects the end of game on a loss' do
      result = CurrentResult.new(nil, 10, nil)
      expect(board.end_of_game?(result)).to eq(true)
    end
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

    it 'returns a hash with number of positions/colors' do
      result_hash = {correct_positions: 1, correct_colors:2}
      expect(code_comparer.compare).to eq(result_hash)
    end
  end

  describe 'Colors' do
    let(:default_colors){%w{R G O Y B P}}
    it 'returns default colors if incorrect size of input array' do
      custom_colors = %w{Q Z F R}
      expect(Colors.new(custom_colors).valid_colors).to match_array(default_colors)
    end

    it 'returns default colors if no arguments' do
      expect(Colors.new.valid_colors).to match_array(default_colors)
    end
  end 

  describe 'NaiveAlgorithm' do
    let (:naive_algorithm){NaiveAlgorithm.new(default_colors)}
    before(:all) do
      result_hash = {correct_positions: 0, correct_colors: 0}
      guess = %w{R R R R}
      @incorrect_guess = CurrentResult.new(guess, nil, result_hash )
    end 

    it 'initializes possible guesses to all permutations' do
      expect(naive_algorithm.possible_guesses.size).to eq(1296)
    end

    it 'chooses a valid next_guess' do
      expect(naive_algorithm.next_guess).to be
    end

    it 'randomizes the next guess' do
      first_guess = naive_algorithm.next_guess
      second_guess = naive_algorithm.next_guess
      expect(first_guess).not_to eq(second_guess)
    end

    it 'discards invalid guesses based on previous result' do
      expect(naive_algorithm.discard_invalid_guesses(@incorrect_guess)).not_to include( %w{R R R R} )
    end

    it 'keeps guesses that are still valid' do
      expect(naive_algorithm.discard_invalid_guesses(@incorrect_guess)).to include( %w{G G G G} )
    end  
  end

  describe 'AIPlayer' do
    let(:algorithm){NaiveAlgorithm.new(DEFAULT_COLORS)}
    let(:board){GameStatus.new(code, DEFAULT_COLORS)}
    let(:ai_player){AIPlayer.new(board, algorithm)}
    let(:solution){CurrentResult.new(code, 1, WIN_HASH )}
    

    it 'calls process_guess once if wins on first try' do
      allow(algorithm).to receive(:next_guess){ code }    
      expect(board).to receive(:process_guess).with(code).and_return(solution)
      ai_player.solve
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
      code = %w{R R R R}
      result = CurrentResult.new(code, 1, WIN_HASH)
      expect(game_text.message(:win, result)).to eq("Solved in 1 try!")
    end
   
    it 'pluralizes winning message' do
      code = %w{R R R R}
      result = CurrentResult.new(code, 2, WIN_HASH)
      expect(game_text.message(:win, result)).to eq("Solved in 2 tries!")
    end
  
    it 'displays losing message' do
      expect(game_text.message(:lose)).to eq("Game over. Unable to solve in 10 turns.")
    end

    it 'prompts user for color scheme' do
      expect(game_text.message(:color_scheme)).to eq("Enter a 6 letter color scheme or press Enter to use default")
    end
  end
    

  describe 'Game' do 
    let(:game_text){GameText.new}
    let(:terminal_obj){double('terminal_obj') }
    let(:game){ Game.new(game_text, terminal_obj) }

#
#    it 'returns input when valid' do
#      allow(Terminal).to receive(:new){terminal_obj}
#      expect(terminal_obj).to receive(:formatted_input).once.ordered.and_return(%w{R R R R} )
#      expect(terminal_obj).to receive(:display)
#
#      result = game.get_input
#      expect(Validator.new(result).valid?).to eq(true)
#    end
#
#    it 'calls the function until valid' do
#      allow(Terminal).to receive(:new){terminal_obj}
#      expect(terminal_obj).to receive(:formatted_input).once.ordered.and_return(%w{Z Z Z Z} )
#      expect(terminal_obj).to receive(:formatted_input).once.ordered.and_return(%w{R R R R} )
#      expect(terminal_obj).to receive(:display)
#      expect(terminal_obj).to receive(:display)
#
#      result = game.get_input
#      expect(Validator.new(result).valid?).to eq(true)
#    end 
#
#    it 'gets a Solution from winning AIPlayer' do 
#      game.set_up_board(%w{R R R R})
#      expect(game.run_ai_player.correct?).to eq(true)
#    end 
#    it 'prints winning end message if win' do
#      code = %w{R R R R}
#      result = CurrentResult.new(code, 1, WIN_HASH)
#      expect{game.end_of_game(result)}.to output("You win!\n").to_stdout
#    end
#
#    it 'prints losing end message if lose' do
#      result = CurrentResult.new(nil, nil, nil)
#      game.set_up_board(%w{R R R R})
#      expect{game.end_of_game(result)}.to output("Haha! You lost!\n").to_stdout
#    end

    it 'runs through the game' do
      allow(terminal_obj).to receive(:display){}
      allow(game_text).to receive(:message)
      expect(game).to receive(:get_input).and_return(%w{R O Y B} )
      expect(game).to receive(:get_color_scheme).and_return(%w{ R G O Y B P})
      game.play_game
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
    it 'accepts a correct code' do
      correct_validator = Validator.new( %w{R G O Y}, 4, DEFAULT_COLORS)
      expect(correct_validator.valid?).to eq(true)
    end 
  
    it 'fails if code length is incorrect' do 
      wrong_length = Validator.new( %w{R R R R R R}, 4, DEFAULT_COLORS)
      expect(wrong_length.valid?).to eq(false)
    end

    

    it 'fails if either letters or code length are incorrect' do
      wrong_letters = Validator.new( %w{R G O Y}, 4, %w{Q W E R T Y})
      expect(wrong_letters.valid?).to eq(false) 
    end
  end
end
