# 1.8.6 doesn't support String#end_with?
unless ''.respond_to?(:end_with?)
  class String
    def end_with?(s)
      ((idx = self.length - s.length) < 0) ? false : (self[idx .. -1] == s)
    end
  end
end
