module Mastermind 
  DEFAULT_COLORS = %w{R G O Y B P}
  class CodeComparer
    def initialize(code, guess)
      @code = code
      @guess = guess
    end

    def compare
      correct_colors = total_correct_colors - correct_positions
      {
        correct_positions: correct_positions, 
        correct_colors: correct_colors
      }
    end
   
    private
 
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
  end

  class Validator
    def initialize(code, code_length, valid_letters)
      @code = code
      @code_length = code_length
      @valid_letters = valid_letters
    end
   
    
    def valid?
      correct_length? && valid_letters?
    end  
    
    private
	
    def correct_length?
      @code.size == @code_length
    end

    def valid_letters?
      @code.uniq.all? do |letter|
      @valid_letters.include?letter
      end
    end
  end

  class Colors
    def initialize(colors = [])
      if(colors.empty? || colors.size != 6)
        @colors = DEFAULT_COLORS
      else 
        @colors = colors
      end 
    end
    
    def valid_colors
      @colors
    end
  end
end
