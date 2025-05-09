require './examples/ascii_gene'

class Stickman
  include Evolvable

  class HeadGene
    include Evolvable::Gene

    def to_s
      @to_s ||= %w[0 4 9 A C D O P Q R b c d g o p q].sample
    end
  end

  class AppendageGene
    include Evolvable::Gene

    OPTIONS = %w[` ^ - _ = \ | /] << ' '

    def to_s
      @to_s ||= OPTIONS.sample
    end
  end

  gene :head, type: 'HeadGene', count: 1
  gene :body, type: 'AsciiGene', count: 1
  gene :appendages, type: 'AppendageGene', count: 4

  CLEAR_SEQUENCE = ("\e[1A\r\033[2K" * 8).freeze

  def self.before_evaluation(population)
    population.evolvables.each do |evolvable|
      puts "\n\n#{evolvable.draw}\n\n"
      print green_text(" Rate Stickman #{population.evolutions_count}.#{evolvable.generation_index + 1}: ")
      evolvable.fitness = gets.to_i
      print CLEAR_SEQUENCE
    end

    (@best_evolvables ||= []) << population.best_evolvable
    animate_best_evolvables if @best_evolvables.count > 1
  end

  def self.animate_best_evolvables
    @best_evolvables.each_with_index do |evolvable, index|
      puts "\n\n#{green_text(evolvable.draw)}\n\n"
      print green_text(" Generation: #{index}\r\n ")
      sleep 0.5
      print "#{CLEAR_SEQUENCE}"
    end
  end

  def self.green_text(text)
    "\e[32m#{text}\e[0m"
  end

  def draw
    canvas.sub!('o', head.to_s)
    canvas.sub!('0', body.to_s)
    appendages.each { |a| canvas.sub!('-', a.to_s) }
    canvas
  end

  private

  def canvas
    @canvas ||= "    o    \n" \
                "   -0-   \n" \
                "   - -   \n" \
  end
end
