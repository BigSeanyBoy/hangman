# frozen_string_literal: true

require 'yaml'

# The Hangman class stores the data and logic for the game
# of hangman
class Hangman
  attr_reader :remaining_attempts, :incorrect_letters, :user_solution

  def initialize(
    secret_word,
    remaining_attempts = 6,
    user_solution = Array.new(secret_word.length, '_ '),
    incorrect_letters = []
  )
    @secret_word = secret_word.split('')
    @remaining_attempts = remaining_attempts
    @user_solution = user_solution
    @incorrect_letters = incorrect_letters
  end

  def print_game_state
    puts @secret_word.to_s
    puts "\nRemaining Attempts: #{@remaining_attempts}"
    puts "\n#{@user_solution.join}"
    puts "\nIncorrect Letters: #{@incorrect_letters}"
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
    return true if @secret_word.join == solution_letters
  end

  def solution_letters
    @user_solution.join.gsub(' ', '')
  end

  def end_game(user_won)
    if user_won
      print_game_state
      puts 'You Win!'
    elsif user_won == false
      puts 'You Lose...'
    end
  end

  def to_yaml
    serialized = YAML.dump(
      {
        secret_word: @secret_word,
        remaining_attempts: @remaining_attempts,
        user_solution: @user_solution,
        incorrect_letters: @incorrect_letters
      }
    )

    Dir.mkdir('output') unless Dir.exist?('output')
    File.open('output/saved_game.yml', 'w') { |file| file.puts serialized }
  end

  def self.from_yaml
    data = YAML.safe_load(File.open('output/saved_game.yml', 'r'), [Symbol])
    new(
      data[:secret_word].join,
      data[:remaining_attempts],
      data[:user_solution],
      data[:incorrect_letters]
    )
  end
end

def user_input(hangman)
  guess = ''
  loop do
    print 'Please enter an unused character A-Z >>> '
    guess = gets.chomp
    break if guess.length == 1 && guess =~ /[A-Za-z]/
  end
  used_letters = hangman.incorrect_letters + hangman.solution_letters.split('')
  used_letters.include?(guess) ? user_input(hangman) : guess
end

def save_and_exit(hangman)
  print 'Would you like to save and exit? (y/n) >>> '
  answer = gets.chomp
  return false unless answer =~ /[Yy]/

  hangman.to_yaml
  true
end

def open_save
  save_path = 'output/saved_game.yml'
  print 'Would you like to open a saved game? (y/n) >>> '
  open_save = gets.chomp
  return false unless File.file?(save_path) && open_save =~ /[Yy]/

  Hangman.from_yaml
end

def game_loop(hangman)
  while hangman.remaining_attempts.positive?
    hangman.print_game_state
    return nil if save_and_exit(hangman) == true

    guess = user_input(hangman)
    return true if hangman.check_letter(guess) == true
  end
  false
end

def main
  word_list = []

  File.open('google-10000-english-no-swears.txt').readlines.each do |line|
    word_list.push(line.chomp) if line.chomp.length.between?(5, 12)
  end

  hangman = open_save
  secret_word = word_list[Random.rand(word_list.length)]
  hangman = Hangman.new(secret_word) if hangman == false

  user_wins = game_loop(hangman)
  hangman.end_game(user_wins)
end

main

# "\t ____\n\t |  |\n\t    |\n\t    |\n\t    |\n\t    |\n\t ___|___"
