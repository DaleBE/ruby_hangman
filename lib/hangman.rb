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

  def initialize(computer, player)
    @computer = computer
    @player = player
    @computers_word = computer.random_word.split('')
    @display_word = Array.new(@computers_word.length, '_')
  end

  def game_start
    puts 'The computer has chosen a word:'
    puts ''
    puts @display_word.join(' ')
    puts ''
    puts 'You will have 12 chances to guess the correct word.'
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

  def game_sequence
    round = 1

    game_start

    while round <= 12
      puts "Round: #{round}"
      play_round
      check_word
      break if @computers_word == @display_word

      round += 1
    end
    puts "The word is: #{@computers_word.join('')}"
  end
end

game = Game.new(Computer.new, Player.new)

game.game_sequence
