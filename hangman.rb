
require 'pstore'

class Game

  def initialize
    game_menu
  end

  def game_menu
    puts "---Game Menu---
          1. New Game
          2. Load Game"
    user_input = gets.chomp 

    if user_input == "1"
      game = Hangman.new
      game.start_game
    elsif user_input == "2"
      store = PStore.new("storagefile")
      games = []

      store.transaction do
        games = store[:games]
      end
      
      game = games[0]
      game.start_game
    end
  end


end

class Hangman
  attr_accessor :hang_word, :progress, :wrong_letters, :correct_letters, :bad_guess_count, :misses_allowed


  def initialize
    @hang_word = choose_word
    @wrong_letters = []
    @correct_letters = []
    @bad_guess_count = 0
    @misses_allowed = 7
    @progress = update_progress
    @game_over = false
  end

  def choose_word()
    words = File.read("5desk.txt").split("\r\n")
    words.select { |word| word.length >= 5 && word.length <= 12 }.sample
  end

  def update_progress
    updated_progress = ""
    @hang_word.length.times do |i|
      letter = @hang_word[i]
      if @correct_letters.include? letter
        updated_progress += letter
      else
        updated_progress += "_"
      end      
    end
    updated_progress
  end

  def sort_guess(guess)
    if guess == "save"
      save_game
    elsif @hang_word.downcase.include? guess
      @correct_letters.push(guess)
    else
      @wrong_letters.push(guess)
      @bad_guess_count += 1
    end
  end

  def show_progress
    puts "#{@progress}. #{@misses_allowed - @bad_guess_count} guesses remaining
    bad guesses: #{@wrong_letters.join(" ")}"
  end

  def guess
    puts "Guess a letter (or save or load)"
    user_guess = gets.chomp.downcase
  end

  def game_over?
    if @misses_allowed <= @bad_guess_count
      puts "Player Loses"
      return true
    elsif !@progress.include?("_")
      puts "Player Wins!"
      return true     
    end
  end

  def save_game
    store = PStore.new("storagefile")
    store.transaction do
      store[:games] ||= Array.new
      store[:games] << self
    end
    return
  end

  def start_game
    until @game_over
      show_progress
      user_guess = guess
      sort_guess(user_guess)
      @progress = update_progress
      @game_over = game_over?
    end
  end

end
