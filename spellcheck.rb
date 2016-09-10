require "byebug"

class TestData
  # TODO use better test data
  def text_with_spelling_mistakes
    "In deeling with students on the hih-school level - that is, the second, third, and forth year of high school - we must bare in mind that to some degree they are at a dificult sychological stage, generaly called adolesence. Students at this level are likely to be confused mentaly, to be subject to involuntery distractions and romantic dreamines. They are basicaly timid or self-consious, they lack frankness and are usualy very sensitive but hate to admit it. They are motivated iether by great ambition, probably out of all proportion to their capabiltys, or by extreme lazines caused by the fear of not suceeding or ataining their objectives. Fundamentaly they want to be kept busy but they refuse to admit it. They are frequently the victims of earlier poor training, and this makes evary effort doubly hard. They are usually wiling to work, but they hate to work without obtaining the results they think they shoud obtain. Their critical faculties are begining to develop and they are critical of their instructers and of the materiels they are given to laern. They are begining to feel the presher of time; and althouh they seldem say so, they really want to be consulted and given an oportunity to direct their own afairs, but they need considerable gidance."
  end

  def short_text_with_mistakes
    "Teh addreis is lvel door number threee"
  end
end

class Dictionary
  # TODO get some real data
  WORD = %w{ the is address level three door number }

  def include?(word)
    WORD.include?(word)
  end

  def letters
    @letters ||= "abcdefghijklmnopqrstuvwxyz".chars
  end
end

class Corrector
  def initialize(dictionary)
    @dictionary = dictionary
  end

  def suggestion(word)
    best_guess(remove_unknown_words(edited_combinations(word).uniq))
  end

  private
  def best_guess(suggested_words)
    # TODO better heuristic
    suggested_words.first
  end

  def edited_combinations(word)
    splits = splits(word)
    missing_letter(splits) + extra_letter(splits) + swapped_letter(splits) + replaced_letter(splits)
  end

  def splits(word)
    (0..word.length - 1).map do |i|
      [i == 0 ? "" : word[0..(i - 1)], word[i..-1]]
    end
  end

  def missing_letter(splits)
    @dictionary.letters.flat_map do |c|
      splits.map { |left, right| left + c + right }
    end
  end

  def extra_letter(splits)
    splits.map { |left, right| left + right[1..-1] }
  end

  def swapped_letter(splits)
    splits
      .select { |left, right| right.size > 1 }
      .map { |left, right| left + right[1] + right[0] + right[2..-1] }
  end

  def replaced_letter(splits)
    @dictionary.letters.flat_map do |c|
      splits.map { |left, right| left + c + right[1..-1] }
    end
  end

  def remove_unknown_words(words)
    words.select { |word| @dictionary.include?(word) }
  end
end

class SpellChecker
  def initialize(string)
    @string = string.downcase
  end

  def check
    puts @string
    words.each do |word|
      unless dictionary.include?(word)
        puts "#{word} - #{corrector.suggestion(word)}"
      end
    end

    nil
  end

  private
  def words
    @string.scan(/[\w']+/)
  end

  def dictionary
    @dictionary ||= Dictionary.new
  end

  def corrector
    @corrector ||= Corrector.new(dictionary)
  end
end

puts SpellChecker.new(TestData.new.short_text_with_mistakes).check
