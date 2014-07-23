module Mastermind
  class CodeGenerator
    def initialize(colors, code_length)
      @colors = colors
      @code_length = code_length
      @terminal = Terminal.new
      @game_text = GameText.new
    end
    
    def get_valid_code
      input = get_input
      unless Validator.new(input, @code_length, @colors ).valid? 
        get_valid_code
      else
        input
      end
    end

    def get_input
      @terminal.display(@game_text.message(:prompt) )
      @terminal.formatted_input
    end
      
  end
end 
