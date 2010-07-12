module CrossStub
  module Arguments #:nodoc:
    module Hash
      class << self

        def parse(hash)
          hash.inject({}) do |memo, (name, val)|
            code = "def #{name} ; Marshal.load(#{quote(Marshal.dump(val))}) ; end"
            memo.merge(:"#{name}" => code)
          end
        end

        def quote(str)
          !str.include?('"') ? %|"#{str}"| :
            str.split('"',-1).map{|s| [%|"#{s}"|,%|'"'|] }.flatten[0..-2].join('+')
        end

      end
    end
  end
end
