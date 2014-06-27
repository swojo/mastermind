require 'mastermind/GameRules'
require 'mastermind/TerminalInterface'
require 'mastermind/GameStatus'
require 'mastermind/AIsolver'

module Mastermind
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
end

if __FILE__ == $0
  Mastermind::NewGame.new.play_game   
end
