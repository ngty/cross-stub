module CrossStub
  module Arguments #:nodoc:
    module Hash
      class << self

        def parse(hash)
          hash.inject({}) do |memo, (name, val)|
            marshalized = Base64.encode64(Marshal.dump(val)).gsub('|','\|')
            code = "def #{name} ; Marshal.load(Base64.decode64(%|#{marshalized}|)) ; end"
            memo.merge(:"#{name}" => code)
          end
        end

      end
    end
  end
end
