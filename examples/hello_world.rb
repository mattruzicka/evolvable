class HelloWorld
  include Evolvable

  class CharGene
    include Evolvable::Gene

    def self.chars
      @chars ||= 32.upto(126).map(&:chr)
    end

    def self.ensure_chars(string)
      @chars.concat(string.chars - chars)
    end

    def to_s
      @to_s ||= self.class.chars.sample
    end
  end

  MAX_STRING_LENGTH = 40

  gene :char_genes, type: 'CharGene', count: 1..MAX_STRING_LENGTH

  def self.start_loop(population)
    loop do
      HelloWorld.seek_target
      prepare_to_exit_loop && break if exit_loop?

      population.reset_evolvables
      population.evolve
    end
  end

  def self.exit_loop?
    ['"exit"', 'exit'].include?(target)
  end

  def self.prepare_to_exit_loop
    print "\n\n\n\n\n #{green_text('Goodbye!')}\n\n\n"
    true
  end

  def self.seek_target
    print "\n\n\n\n\n #{green_text('Use "exit" to stop')} \e[1A\e[1A\e[1A\r" \
    " #{green_text('Enter a string to evolve: ')}"
    self.target = gets.strip!
  end

  def self.target=(val)
    @target = if val.empty?
                'I chose this string :)'
              else
                CharGene.ensure_chars(val)
                val.slice(0...MAX_STRING_LENGTH)
              end
  end

  def self.target
    @target ||= 'Hello World!'
  end

  def self.before_evolution(population)
    best_evolvable = population.best_evolvable
    spacing = ' ' * (2 + MAX_STRING_LENGTH - best_evolvable.to_s.length)
    puts " #{best_evolvable}#{spacing}#{green_text("Generation #{population.evolutions_count}")}"
  end

  def self.green_text(text)
    "\e[32m#{text}\e[0m"
  end

  def to_s
    @to_s ||= genes.join
  end

  def fitness
    @fitness ||= compute_fitness
  end

  private

  def compute_fitness
    string = to_s
    target = self.class.target
    target_length = target.length
    char_matches = target.each_char.with_index.count { |chr, i| chr == string[i] }
    (target_length - char_matches) + (target_length - string.length).abs
  end
end
