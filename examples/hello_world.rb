class HelloWorld
  include Evolvable

  class CharGene
    include Evolvable::Gene

    class << self
      def chars
        @chars ||= 32.upto(126).map(&:chr)
      end

      def ensure_chars(string)
        @chars.concat(string.chars - chars)
      end
    end

    def to_s
      @to_s ||= self.class.chars.sample
    end
  end

  class << self
    MAX_STRING_LENGTH = 40

    def gene_space
      { char_genes: { type: 'CharGene', count: 1..MAX_STRING_LENGTH } }
    end

    def start_loop(population)
      loop do
        HelloWorld.seek_target
        population.reset_instances
        population.evolve
      end
    end

    def seek_target
      print "\n\n\n\n\n #{green_text('Use Ctrl-C to stop')} \e[1A\e[1A\e[1A\r" \
      " #{green_text('Enter a string to evolve: ')}"
      self.target = gets.strip!
    end

    def target=(val)
      @target = if val.empty?
                  'I chose this string :)'
                else
                  CharGene.ensure_chars(val)
                  val.slice!(0...MAX_STRING_LENGTH)
                end
    end

    def target
      @target ||= 'Hello Evolvable World!'
    end

    def before_evolution(population)
      best_instance = population.best_instance
      spacing = ' ' * (2 + MAX_STRING_LENGTH - best_instance.to_s.length)
      puts " #{best_instance}#{spacing}#{green_text("Generation #{population.evolutions_count}")}"
    end

    def green_text(text)
      "\e[32m#{text}\e[0m"
    end
  end

  def to_s
    @to_s ||= genes.join
  end

  def value
    @value ||= compute_value
  end

  private

  def compute_value
    string = to_s
    target = self.class.target
    target_length = target.length
    char_matches = target.each_char.with_index.count { |chr, i| chr == string[i] }
    (target_length - char_matches) + (target_length - string.length).abs
  end
end
