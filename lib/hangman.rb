require 'yaml'

class Computer
  attr_reader :random_word

  def initialize
    @random_word = generate_random_word
  end

  def generate_random_word
    dictionary = File.readlines('hangman_library.txt')

    word_array = dictionary.filter_map do |word|
      word.chomp if word.length >= 6 && word.length <= 13
    end

    word_array[rand(0..word_array.length - 1)]
  end
end

class Player
  attr_reader :letter_guess, :wrong_guesses

  def initialize
    @letter_guess = ''
    @wrong_guesses = []
  end

  def choose_letter
    puts 'Please choose a letter:'
    @letter_guess = gets.chomp.downcase
  end
end

class Game
  attr_reader :computer, :player, :computers_word, :display_word
  attr_accessor :round

  def initialize(computer, player, round = 1)
    @computer = computer
    @player = player
    @computers_word = computer.random_word.split('')
    @display_word = Array.new(@computers_word.length, '_')
    @round = round
  end

  def new_game_start
    puts 'The computer has chosen a word:'
    puts ''
    puts @display_word.join(' ')
    puts ''
  end

  def play_round
    @player.choose_letter

    if @computers_word.include?(@player.letter_guess)
      assign_letters
    else
      @player.wrong_guesses.push(@player.letter_guess)
      puts 'Sorry, that letter isn\'t in the word.'
      puts "Wrong guesses: #{@player.wrong_guesses.join(' ')}"
    end
  end

  def assign_letters
    indexes = @computers_word.each_index.select { |index| @computers_word[index] == @player.letter_guess }
    indexes.each { |index| @display_word[index] = @player.letter_guess }
    puts @display_word.join(' ')
  end

  def check_word
    if @display_word == @computers_word
      puts 'Congratulations! You guessed it.'
    else
      puts 'Please guess again...'
      puts @display_word.join(' ')
    end
  end
end

class GameStart
  attr_reader :game, :choice

  def initialize
    @game = game
    @choice = choice
  end

  def beginning
    puts 'Welcome to the game of Hangman!'
    puts 'The computer will choose a word and you have'
    puts '12 chances to guess the word.'
    puts 'Would you like to play a saved game or start anew? ( saved/new )'
    @choice = gets.chomp.downcase
  end

  def save_game
    puts 'Do you wish to save the game? (save)'
    choice = gets.chomp!.downcase

    return unless choice == 'save'

    saved_game = File.new('saved_game.yml', 'w')
    saved_game.puts @game.to_yaml
    saved_game.close
  end

  def start
    beginning

    if @choice == 'new'
      @game = Game.new(Computer.new, Player.new)
      @game.new_game_start
      game_sequence
    elsif @choice == 'saved'
      @game = Psych.safe_load_file('saved_game.yml', permitted_classes: [Game, Computer, Player])
      puts @game.display_word.join(' ')
      game_sequence
    end
  end

  def game_sequence
    while @game.round <= 12
      save_game
      puts "Round: #{@game.round}"
      @game.play_round
      @game.check_word
      break if @game.computers_word == @game.display_word

      @game.round += 1
    end
    puts "The word is: #{@game.computers_word.join('')}"
  end
end

hangman = GameStart.new
hangman.start
