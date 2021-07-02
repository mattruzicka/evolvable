require './examples/ascii_gene'

class AsciiArt
  include Evolvable

  class << self
    def search_space
      { chars: { type: 'AsciiGene', count: 136 } }
    end

    def before_evaluation(population)
      population.best_instance.to_terminal
    end
  end

  CLEAR_SEQUENCE = ("\e[1A\r\033[2K" * 14).freeze

  def to_terminal
    print(CLEAR_SEQUENCE) unless population.evolutions_count.zero?
    lines = genes.each_slice(17).flat_map(&:join)
    lines[0] = "\n    #{lines[0]}     #{green_text('Minimalism Score:')} #{value}"
    lines[1] << "     #{green_text('Generation:')} #{population.evolutions_count}"
    print "\n\n#{lines.join("\n    ")}\n\n\n\n   #{green_text('Use Ctrl-C to stop')} "
  end

  def minimalism_score
    @minimalism_score ||= essence_score + spacial_score - clutter_score
  end

  alias value minimalism_score

  private

  def chars
    @chars ||= genes.map(&:to_s)
  end

  def essence_score
    chars.each_slice(16).each_cons(3).sum do |top, middle, bottom|
      top_cons = top.each_cons(3).to_a
      bottom_cons = bottom.each_cons(3).to_a
      middle.each_cons(3).with_index.sum do |middle_chars, index|
        mid_center_char = middle_chars.delete_at(1)
        count = middle_chars.count(mid_center_char)
        count += top_cons[index].count(mid_center_char)
        count + (bottom_cons[index]&.count(mid_center_char) || 0)
      end
    end
  end

  def spacial_score
    chars.count { |c| c == ' ' }
  end

  def clutter_score
    chars.uniq.count
  end

  def green_text(text)
    "\e[32m#{text}\e[0m"
  end
end
