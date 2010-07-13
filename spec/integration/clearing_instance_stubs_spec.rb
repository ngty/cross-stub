require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Clearing Instance Stubs' do

  %w{current other}.each do |mode|
    %w{AnyClass AnyClass::Inner}.each do |klass|

      describe '>> %s process (%s instance)' % [mode, klass] do

        behaves_like 'has standard setup'
        behaves_like "has #{mode} process setup"

        before do
          @klass = @get_context[klass]
          @instance = @klass.new
        end

        should "clear hash generated stub and return original value" do
          original_value = @instance.say_hello
          @klass.xstub({:say_hello => 'i say hello'}, :instance => true)
          CrossStub.clear
          @get_value["#{@klass}::new.say_hello"].should.equal original_value
        end

        should "clear hash generated stub and raise NoMethodError" do
          should.raise(NoMethodError) do
            @klass.xstub({:say_hi => 'i say hi'}, :instance => true)
            CrossStub.clear
            @get_value["#{@klass}::new.say_hi"]
          end
        end

        should "clear symbol generated stub and return original value" do
          original_value = @instance.say_hello
          @klass.xstub(:say_hello, :instance => true)
          CrossStub.clear
          @get_value["#{@klass}::new.say_hello"].should.equal original_value
        end

        should "clear symbol generated stub and raise NoMethodError" do
          should.raise(NoMethodError) do
            @klass.xstub(:say_hi, :instance => true)
            CrossStub.clear
            @get_value["#{@klass}::new.say_hi"]
          end
        end

        should "clear block generated stub and return original value" do
          original_value = @instance.say_hello
          @klass.xstub(:instance => true) do
            def say_hello ; 'i say hello' ; end
          end
          CrossStub.clear
          @get_value["#{@klass}::new.say_hello"].should.equal original_value
        end

        should "clear block generated stub and raise NoMethodError" do
          should.raise(NoMethodError) do
            @klass.xstub(:instance => true) do
              def say_hi ; 'i say hi' ; end
            end
            CrossStub.clear
            @get_value["#{@klass}::new.say_hi"]
          end
        end

        should "always clear previously generated stub" do
          original_value = @instance.say_hello

          # Stub an existing method
          @klass.xstub({:say_hello => 'i say hello'}, :instance => true)
          @get_value["#{@klass}::new.say_hello"]

          # Clear stubs without refreshing another process
          CrossStub.clear
          CrossStub.setup(:file => $cache_file)

          # Stub a non-existing method
          @klass.xstub({:say_hi => 'i say hi'}, :instance => true)
          @get_value["#{@klass}::new.say_hi"]

          # Make sure existing method returns to original method
          @get_value["#{@klass}::new.say_hello"].should.equal original_value
        end

        should "always clear previously generated stub and raise NoMethodError" do
          # Stub a non-existing method
          @klass.xstub({:say_hi => 'i say hi'}, :instance => true)
          @get_value["#{@klass}::new.say_hi"]

          # Clear stubs without refreshing another process
          CrossStub.clear
          CrossStub.setup(:file => $cache_file)

          # Stub an existing method
          @klass.xstub({:say_hello => 'i say hello'}, :instance => true)
          @get_value["#{@klass}::new.say_hello"]

          # Make sure accessing non-existing method throws error
          should.raise(NoMethodError) { @get_value["#{@klass}::new.say_hi"] }
        end

      end

    end
  end

end
