class CharGene
  include Evolvable::Gene

  CHARS = ('a'..'z').to_a

  def to_s
    @to_s ||= CHARS.sample
  end
end
