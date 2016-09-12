require "byebug"

class Dictionary
  def include?(word)
    !words[word].nil?
  end

  def occurences(word)
    words[word]
  end

  def letters
    @letters ||= "abcdefghijklmnopqrstuvwxyz".chars
  end

  private
  def words
    @words ||= begin
      @words = {}
      File.open("count_big.txt").each do |line|
        word, count = line.chomp.split("\t")
        @words[word] = count.to_i
      end
      @words
    end
  end
end

class Corrector
  def initialize(dictionary)
    @dictionary = dictionary
  end

  def suggestion(word)
    one_letter_combinations = edited_combinations(word)
    best_guess(remove_non_words_and_add_occurences(one_letter_combinations))
  end

  private
  def best_guess(suggested_words_with_count)
    suggested_words_with_count.empty? ? "" : suggested_words_with_count.sort_by(&:last).last.first
  end

  def edited_combinations(word)
    splits = splits(word)
    (missing_letter(splits) + extra_letter(splits) + swapped_letter(splits) + replaced_letter(splits)).uniq
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

  def remove_non_words_and_add_occurences(combinations)
    combinations.reduce({}) do |result, combination|
      count = @dictionary.occurences(combination)
      result[combination] = count if count
      result
    end
  end
end

class SpellChecker
  def initialize(string, dictionary)
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

string = "In deeling with students on the hih-school level - that is, the second, third, and forth year of high school - we must bare in mind that to some degree they are at a dificult sychological stage, generaly called adolesence. Students at this level are likely to be confused mentaly, to be subject to involuntery distractions and romantic dreamines. They are basicaly timid or self-consious, they lack frankness and are usualy very sensitive but hate to admit it. They are motivated iether by great ambition, probably out of all proportion to their capabiltys, or by extreme lazines caused by the fear of not suceeding or ataining their objectives. Fundamentaly they want to be kept busy but they refuse to admit it. They are frequently the victims of earlier poor training, and this makes evary effort doubly hard. They are usually wiling to work, but they hate to work without obtaining the results they think they shoud obtain. Their critical faculties are begining to develop and they are critical of their instructers and of the materiels they are given to laern. They are begining to feel the presher of time; and althouh they seldem say so, they really want to be consulted and given an oportunity to direct their own afairs, but they need considerable gidance."

class Zero643Reader
  def appling
    count = 0
    matched = 0
    File.open("0643/APPLING1DAT.643").each do |line|
      next if line.start_with?("$")
      original, expected, _ = line.split
      suggestion = corrector.suggestion(original)
      puts "#{original} - #{suggestion} - #{expected}"
      matched += 1 if suggestion == expected
      count += 1
    end

    puts "*****"
    puts "#{count} - #{matched} - #{(matched/count.to_f * 100).round}%"
  end

  def sheffield
    count = 0
    matched = 0
    File.open("0643/SHEFFIELDDAT.643").each do |line|
      next if line.start_with?("$")
      expected, original, _ = line.split
      expected.downcase!
      original.downcase!
      suggestion = corrector.suggestion(original)
      puts "#{original} - #{suggestion} - #{expected}"
      matched += 1 if suggestion == expected
      count += 1
    end

    puts "*****"
    puts "#{count} - #{matched} - #{(matched/count.to_f * 100).round}%"
  end

  private
  def dictionary
    @dictionary ||= Dictionary.new
  end

  def corrector
    @corrector ||= Corrector.new(dictionary)
  end
end

Zero643Reader.new.sheffield
