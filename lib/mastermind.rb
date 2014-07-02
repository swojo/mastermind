require_relative './mastermind/GameRules'
require_relative './mastermind/TerminalInterface'
require_relative './mastermind/GameStatus'
require_relative './mastermind/AIsolver'

module Mastermind
  class NewGame
    def initialize
      @game_text = GameText.new
      @terminal = Terminal.new
      @code_length = 4
    end
    
    def play_game
      @terminal.display(@game_text.message(:welcome))
      colors = get_color_scheme
      code = get_input(colors)
      set_up_board(code, colors)
      result = run_ai_player
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
  end 
end

if __FILE__ == $0
  Mastermind::NewGame.new.play_game   
end
