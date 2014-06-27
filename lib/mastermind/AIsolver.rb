module Mastermind
  class NaiveAlgorithm
    attr_accessor :possible_guesses

    def initialize(valid_letters)
      @valid_letters = valid_letters
      @possible_guesses = valid_letters.repeated_permutation(4).to_a
    end
   
    def rand_index
      rand(@possible_guesses.size)
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
    def initialize(board)
      @board = board
      @valid_letters = @board.valid_letters
      @algorithm = NaiveAlgorithm.new(@valid_letters)
    end
   
    def solve
      next_guess = @algorithm.next_guess
      result = @board.process_guess(next_guess)
      return result if result.correct? || result.num_of_tries == 10
      
      @algorithm.discard_invalid_guesses(result)
      solve
    end
  end
end
