require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Clearing Stubs' do

  behaves_like 'has standard setup'

  %w{current other}.each do |mode|

    behaves_like "has #{mode} process setup"

    %w{AnyClass OuterModule::InnerModule}.each do |konst|

      before do
        # gets back the nested module via incremental const_gets
        @klass = konst.split(/::/).inject(Object) { |const_train, const| const_train.const_get(const) }
      end

      it "should clear hash generated stub and return original value for #{konst} class in #{mode} process" do
        original_value = @klass.say_world
        @klass.xstub(:say_world => 'i say world')
        CrossStub.clear
        @get_value["#{@klass}.say_world"].should.equal original_value
      end

      it "should clear hash generated stub and raise NoMethodError for #{konst} class in #{mode} process" do
        should.raise(NoMethodError) do
          @klass.xstub(:say_hello => 'i say hello')
          CrossStub.clear
          @get_value["#{@klass}.say_hello"]
        end
      end

      it "should clear symbol generated stub and return original value for #{konst} class in #{mode} process" do
        original_value = @klass.say_world
        @klass.xstub(:say_world)
        CrossStub.clear
        @get_value["#{@klass}.say_world"].should.equal original_value
      end

      it "should clear symbol generated stub and raise NoMethodError for #{konst} class in #{mode} process" do
        should.raise(NoMethodError) do
          @klass.xstub(:say_hello)
          CrossStub.clear
          @get_value["#{@klass}.say_hello"]
        end
      end

      it "should clear block generated stub and return original value for #{konst} class in #{mode} process" do
        original_value = @klass.say_world
        @klass.xstub do
          def say_world ; 'i say world' ; end
        end
        CrossStub.clear
        @get_value["#{@klass}.say_world"].should.equal original_value
      end

      it "should clear block generated stub and raise NoMethodError for #{konst} class in #{mode} process" do
        should.raise(NoMethodError) do
          @klass.xstub do
            def say_hello ; 'i say hello' ; end
          end
          CrossStub.clear
          @get_value["#{@klass}.say_hello"]
        end
      end

      it "should always clear previously generated stub for #{konst} class in #{mode} process" do
        original_value = @klass.say_world

        # Stub an existing method
        @klass.xstub(:say_world => 'i say world')
        @get_value["#{@klass}.say_world"]

        # Clear stubs without refreshing another process
        CrossStub.clear
        CrossStub.setup(:file => $cache_file)

        # Stub a non-existing method
        @klass.xstub(:say_hello => 'i say hello')
        @get_value["#{@klass}.say_hello"]

        # Make sure existing method returns to original method
        @get_value["#{@klass}.say_world"].should.equal original_value
      end

      it "should always clear previously generated stub and raise NoMethodError for #{konst} class in #{mode} process" do
        # Stub a non-existing method
        @klass.xstub(:say_hello => 'i say hello')
        @get_value["#{@klass}.say_hello"]

        # Clear stubs without refreshing another process
        CrossStub.clear
        CrossStub.setup(:file => $cache_file)

        # Stub an existing method
        @klass.xstub(:say_world => 'i say world')
        @get_value["#{@klass}.say_world"]

        # Make sure accessing non-existing method throws error
        should.raise(NoMethodError) { @get_value["#{@klass}.say_hello"] }
      end

      it "should clear for method not implemented in ruby and return original value for #{konst} class in #{mode} process" do
        Time.xstub(:now => 'abc')
        CrossStub.clear
        value = nil
        should.not.raise(NoMethodError) { value = @get_value['Time.now'] }
        value.should.not.equal 'abc'
      end
    end
  end

end
