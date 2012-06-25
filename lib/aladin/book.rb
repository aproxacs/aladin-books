module Aladin
  class Book < OpenStruct
    def initialize(hash = {})
      super(nil)
      hash.each do |key, value|
        send("#{key.to_s.underscore}=", value)
      end
    end
  end
end