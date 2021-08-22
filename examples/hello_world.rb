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

    # TODO: Extract the below comment into tests and documentation

    # Gene Space Definition Options
    # All of the below result in the same behavior for this particular
    # program since it simply finds its name via the #genes method

    # Hash definition
    # { char_genes: { type: 'CharGene', count: 1..MAX_STRING_LENGTH } }

    # Array of arrays definition
    # [[:char_genes, 'CharGene', 1..MAX_STRING_LENGTH]]
    # [['char_genes', 'CharGene',  1..MAX_STRING_LENGTH]]
    # [['CharGene', 1..MAX_STRING_LENGTH]]

    # Single array for when there's only one type of gene
    # ['CharGene', 1..MAX_STRING_LENGTH]
    # [:char_genes, 'CharGene', 1..MAX_STRING_LENGTH]
    # ['char_genes', 'CharGene', 1..MAX_STRING_LENGTH]

    def search_space
      { char_genes: { type: 'CharGene', count: 1..MAX_STRING_LENGTH } }
    end

    def start_loop(population)
      loop do
        HelloWorld.seek_target
        prepare_to_exit_loop && break if exit_loop?

        population.reset_evolvables
        population.evolve
      end
    end

    def exit_loop?
      ['"exit"', 'exit'].include?(target)
    end

    def prepare_to_exit_loop
      print "\n\n\n\n\n #{green_text('Goodbye!')}\n\n\n"
      true
    end

    def seek_target
      print "\n\n\n\n\n #{green_text('Use "exit" to stop')} \e[1A\e[1A\e[1A\r" \
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
      best_evolvable = population.best_evolvable
      spacing = ' ' * (2 + MAX_STRING_LENGTH - best_evolvable.to_s.length)
      puts " #{best_evolvable}#{spacing}#{green_text("Generation #{population.evolutions_count}")}"
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
