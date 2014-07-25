require_relative './mastermind_cmdline/GameRules'
require_relative './mastermind_cmdline/TerminalInterface'
require_relative './mastermind_cmdline/GameStatus'
require_relative './mastermind_cmdline/AIsolver'

module Mastermind
  class Game
    def initialize(game_text, terminal)
      @game_text = game_text
      @terminal = terminal
      @code_length = 4
    end
    
    def play_game
      @terminal.display(@game_text.message(:welcome))
      colors = get_color_scheme
      code = get_input(colors)
      set_up_board(code, colors)
      result = run_ai_player(colors)
      end_of_game(result)
    end
    
    private
    
    def get_color_scheme
      @terminal.display(@game_text.message(:color_scheme))
      colors = @terminal.formatted_input 
      Colors.new(colors).valid_colors
    end
   
    def get_input(colors)
      @terminal.display(@game_text.message(:prompt) )
      input = @terminal.formatted_input
      unless Validator.new(input, @code_length, colors ).valid? 
        get_input(colors)
      else
        input
      end
    end
 
    def set_up_board(code, colors)
      @board = GameStatus.new(code, colors)
    end

    def run_ai_player(colors)
      algorithm = NaiveAlgorithm.new(colors)
      player = AIPlayer.new(@board, algorithm)
      result = player.solve
      print_guess(result)
      until @board.end_of_game?(result)
        result = player.solve
        print_guess(result)
      end
      result
    end

    def print_guess(result)
      @terminal.display(@game_text.message(:guess, result))
    end

    def end_of_game(result)
      if(result.correct?)
        @terminal.display(@game_text.message(:win, result))
      else
        @terminal.display(@game_text.message(:lose, result))
      end
    end
  end 
end

