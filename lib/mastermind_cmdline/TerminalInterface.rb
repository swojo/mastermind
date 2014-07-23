module Mastermind
  class Terminal
    def display(message)
      puts message 
    end 

    def formatted_input(stdin = $stdin)
       stdin.gets.upcase.split(%r{\s*} )
    end
  end

  class GameText 
    def message(message_type, game_result = [])
     case message_type
      when :welcome
        "Welcome To Mastermind"
      when :prompt
        "Please Enter the Code: "
      when :guess
        "#{game_result.guess}"
      when :win
        if(game_result.num_of_tries == 1)
          "Solved in #{game_result.num_of_tries} try!"
        else
          "Solved in #{game_result.num_of_tries} tries!"
        end
      when :lose
        "Game over. Unable to solve in 10 turns."
      when :color_scheme
        "Enter a 6 letter color scheme or press Enter to use default"  
      else 
        "Come again?"
     end
   end
 end

end 
