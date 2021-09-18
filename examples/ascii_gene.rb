class AsciiGene
  include Evolvable::Gene

  ASCII_RANGE = 32..126

  def to_s
    @to_s ||= rand(ASCII_RANGE).chr
  end
end