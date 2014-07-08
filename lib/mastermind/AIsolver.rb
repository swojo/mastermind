module Mastermind
  class NaiveAlgorithm
    attr_accessor :possible_guesses

    def initialize(valid_letters)
      @valid_letters = valid_letters
      @possible_guesses = valid_letters.repeated_permutation(4).to_a
    end
   
    def next_guess
       @possible_guesses[rand(@possible_guesses.size)]
    end

    def discard_invalid_guesses(incorrect_guess)
      discarded_guesses = @possible_guesses.select do |guess|
        compare_result = CodeComparer.new(incorrect_guess.guess, guess).compare
        compare_result != incorrect_guess.result_hash
      end
      @possible_guesses -= discarded_guesses
    end
  end

  class AIPlayer
    def initialize(board, algorithm)
      @board = board
      @algorithm = algorithm
    end
   
    def solve
      next_guess = @algorithm.next_guess
      result = @board.process_guess(next_guess)
      return result if @board.end_of_game?(result)
      
      @algorithm.discard_invalid_guesses(result)
      solve
    end
  end
end
