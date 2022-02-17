# frozen_string_literal: true

# The Hangman class stores the data and logic for the game
# of hangman
class Hangman
  attr_reader :remaining_attempts, :incorrect_letters

  def initialize(secret_word)
    @secret_word = secret_word.split('')
    @remaining_attempts = 6
    @user_solution = Array.new(secret_word.length, '_ ')
    @incorrect_letters = []
  end

  def print_game_state
    puts @secret_word.to_s
    puts "\nRemaining Attempts: #{@remaining_attempts}"
    puts "\n#{@user_solution.join}"
    puts "\nLetters Used: #{@incorrect_letters}"
  end

  def check_letter(letter)
    letter.downcase!
    if @secret_word.include?(letter)
      @secret_word.each_index do |i|
        @user_solution[i] = "#{letter} " if @secret_word[i] == letter
      end
    else
      @remaining_attempts -= 1
      @incorrect_letters.push(letter)
    end
    return true if @secret_word.join == @user_solution.join.gsub(' ', '')
  end

  def end_game(user_won)
    if user_won
      print_game_state
      puts 'You Win!'
    else
      puts 'You Lose...'
    end
  end
end

def user_input
  print 'What is your guess? >>> '
  guess = gets.chomp
  until guess.length == 1 && guess =~ /[A-Za-z]/
    print 'Please enter an unused character A-Z >>> '
    guess = gets.chomp
  end
  guess
end

def game_loop(hangman)
  while hangman.remaining_attempts.positive?
    hangman.print_game_state
    guess = user_input
    return true if hangman.check_letter(guess) == true
  end
  false
end

def main
  word_list = []

  File.open('google-10000-english-no-swears.txt').readlines.each do |line|
    word_list.push(line.chomp) if line.chomp.length.between?(5, 12)
  end

  hangman = Hangman.new(word_list[Random.rand(word_list.length)])

  user_wins = game_loop(hangman)
  hangman.end_game(user_wins)
end

main

# "\t ____\n\t |  |\n\t    |\n\t    |\n\t    |\n\t    |\n\t ___|___"
