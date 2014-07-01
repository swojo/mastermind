module Mastermind
  WIN_HASH = {correct_positions: 4, correct_colors:0}

  class GameStatus
    def initialize(code)
      @code = code
      @num_of_tries = 0
    end
    
    def valid_letters
      %w{R G O Y B P}
    end

    def process_guess(guess)
      @num_of_tries += 1
      if win?(guess)
        #Is it worth checking win separately here?
        result_hash = WIN_HASH 
      else
        result_hash = CodeComparer.new(@code, guess).compare
      end
      CurrentResult.new(guess, num_of_tries, result_hash) 
    end

    def end_of_game?(result)
      win?(result.guess) || result.num_of_tries == 10
    end

   
    private
 
    def win?(guess)
      @code == guess
    end
  end

  class CurrentResult
    attr_reader :result_hash
    attr_reader :num_of_tries, :guess

    def initialize(guess, num_of_tries, result_hash)
      @guess = guess
      @num_of_tries = num_of_tries
      @result_hash = result_hash
    end

    def correct?   
      @result_hash == WIN_HASH
    end
  end
end
