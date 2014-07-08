require_relative './mastermind/GameLoop'
require_relative './mastermind/GameRules'
require_relative './mastermind/TerminalInterface'
require_relative './mastermind/GameStatus'
require_relative './mastermind/AIsolver'

include Mastermind

game_text = GameText.new
terminal = Terminal.new

Game.new(game_text, terminal).play_game

