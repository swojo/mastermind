require_relative 'GameRules'
require_relative 'TerminalInterface'
require_relative 'GameStatus'
require_relative 'AIsolver'
require_relative 'UserInterface'

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
      CodeGenerator.new(colors, @code_length).get_valid_code
    end
 
    def set_up_board(code, colors)
      @board = GameStatus.new(code, colors)
    end

    def run_ai_player(colors)
      algorithm = NaiveAlgorithm.new(colors)
      AIPlayer.new(@board, algorithm).solve
    end

    def end_of_game(result)
      if(result.correct?)
        @terminal.display(@game_text.message(:win))
      else
        @terminal.display(@game_text.message(:lose))
      end
    end
  end 
end

if __FILE__ == $0
  Mastermind::Game.new.play_game   
end
