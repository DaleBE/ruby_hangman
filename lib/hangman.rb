def generate_random_word
  dictionary = File.readlines('hangman_library.txt')

  word_array = dictionary.filter_map do |word|
    word.chomp if word.length >= 6 && word.length <= 13
  end

  word_array[rand(0..word_array.length - 1)]
end

puts generate_random_word
