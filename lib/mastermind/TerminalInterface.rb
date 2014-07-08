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
    def message(message_type, game_result = {})
     case message_type
      when :welcome
        "Welcome To Mastermind"
      when :prompt
        "Please Enter the Code: "
      when :win
        "You win!"
      when :lose
        "Haha! You lost!"
      when :color_scheme
        "Enter a 6 letter color scheme or press Enter to use default"  
      else 
        "Come again?"
     end
   end
 end

end 
