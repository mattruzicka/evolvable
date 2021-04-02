module Evolvable
  class NullStore < DataStore
    def save_generation?(_population)
      false
    end
  end
end

