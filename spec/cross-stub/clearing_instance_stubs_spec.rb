require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Clearing Instance Stubs' do

  behaves_like 'has standard setup'

  %w{current other}.each do |mode|

    behaves_like "has #{mode} process setup"

    before do
      @klass = AnyClass
      @instance = @klass.new
    end

    it "should clear hash generated stub and return original value for AnyClass instance in #{mode} process" do
      original_value = @instance.say_hello
      @klass.xstub_instances(:say_hello => 'i say hello')
      CrossStub.clear
      @get_value["#{@klass}::new.say_hello"].should.equal original_value
    end

    it "should clear hash generated stub and raise NoMethodError for AnyClass instance in #{mode} process" do
      should.raise(NoMethodError) do
        @klass.xstub_instances(:say_hi => 'i say hi')
        CrossStub.clear
        @get_value["#{@klass}::new.say_hi"]
      end
    end

    it "should clear symbol generated stub and return original value for AnyClass instance in #{mode} process" do
      original_value = @instance.say_hello
      @klass.xstub_instances(:say_hello)
      CrossStub.clear
      @get_value["#{@klass}::new.say_hello"].should.equal original_value
    end

    it "should clear symbol generated stub and raise NoMethodError for AnyClass instance in #{mode} process" do
      should.raise(NoMethodError) do
        @klass.xstub_instances(:say_hi)
        CrossStub.clear
        @get_value["#{@klass}::new.say_hi"]
      end
    end

    it "should clear block generated stub and return original value for AnyClass instance in #{mode} process" do
      original_value = @instance.say_hello
      @klass.xstub_instances do
        def say_hello ; 'i say hello' ; end
      end
      CrossStub.clear
      @get_value["#{@klass}::new.say_hello"].should.equal original_value
    end

    it "should clear block generated stub and raise NoMethodError for AnyClass instance in #{mode} process" do
      should.raise(NoMethodError) do
        @klass.xstub_instances do
          def say_hi ; 'i say hi' ; end
        end
        CrossStub.clear
        @get_value["#{@klass}::new.say_hi"]
      end
    end

    it "should always clear previously generated stub for AnyClass instance in #{mode} process" do
      original_value = @instance.say_hello

      # Stub an existing method
      @klass.xstub_instances(:say_hello => 'i say hello')
      @get_value["#{@klass}::new.say_hello"]

      # Clear stubs without refreshing another process
      CrossStub.clear
      CrossStub.setup(:file => $cache_file)

      # Stub a non-existing method
      @klass.xstub_instances(:say_hi => 'i say hi')
      @get_value["#{@klass}::new.say_hi"]

      # Make sure existing method returns to original method
      @get_value["#{@klass}::new.say_hello"].should.equal original_value
    end

    it "should always clear previously generated stub and raise NoMethodError for AnyClass instance in #{mode} process" do
      # Stub a non-existing method
      @klass.xstub_instances(:say_hi => 'i say hi')
      @get_value["#{@klass}::new.say_hi"]

      # Clear stubs without refreshing another process
      CrossStub.clear
      CrossStub.setup(:file => $cache_file)

      # Stub an existing method
      @klass.xstub_instances(:say_hello => 'i say hello')
      @get_value["#{@klass}::new.say_hello"]

      # Make sure accessing non-existing method throws error
      should.raise(NoMethodError) { @get_value["#{@klass}::new.say_hi"] }
    end
  end
end
