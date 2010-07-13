require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Clearing Instance Stubs' do

  %w{current other}.each do |mode|
    %w{AnyInstance AnyInstance::Inner}.each do |klass|

      describe '>> %s process (%s instance)' % [mode, klass] do

        behaves_like 'has standard setup'
        behaves_like "has #{mode} process setup"

        before do
          @klass = @get_context[klass]
          @instance = @klass.new
        end

        should "clear hash generated stub and return original value" do
          original_value = @instance.say
          @klass.xstub({:say => 'HELLO'}, :instance => true)
          CrossStub.clear
          @get_value["#{@klass}::new.say"].should.equal original_value
        end

        should "clear hash generated stub and raise NoMethodError" do
          should.raise(NoMethodError) do
            @klass.xstub({:blurb => 'blah blah'}, :instance => true)
            CrossStub.clear
            @get_value["#{@klass}::new.blurb"]
          end
        end

        should "clear symbol generated stub and return original value" do
          original_value = @instance.say
          @klass.xstub(:say, :instance => true)
          CrossStub.clear
          @get_value["#{@klass}::new.say"].should.equal original_value
        end

        should "clear symbol generated stub and raise NoMethodError" do
          should.raise(NoMethodError) do
            @klass.xstub(:blurb, :instance => true)
            CrossStub.clear
            @get_value["#{@klass}::new.blurb"]
          end
        end

        should "clear block generated stub and return original value" do
          original_value = @instance.say
          @klass.xstub(:instance => true) do
            def say ; 'HELLO' ; end
          end
          CrossStub.clear
          @get_value["#{@klass}::new.say"].should.equal original_value
        end

        should "clear block generated stub and raise NoMethodError" do
          should.raise(NoMethodError) do
            @klass.xstub(:instance => true) do
              def blurb ; 'blah blah' ; end
            end
            CrossStub.clear
            @get_value["#{@klass}::new.blurb"]
          end
        end

        should "always clear previously generated stub" do
          original_value = @instance.say

          # Stub an existing method
          @klass.xstub({:say => 'HELLO'}, :instance => true)
          @get_value["#{@klass}::new.say"]

          # Clear stubs without refreshing another process
          CrossStub.clear
          CrossStub.setup(:file => $cache_file)

          # Stub a non-existing method
          @klass.xstub({:blurb => 'blah blah'}, :instance => true)
          @get_value["#{@klass}::new.blurb"]

          # Make sure existing method returns to original method
          @get_value["#{@klass}::new.say"].should.equal original_value
        end

        should "always clear previously generated stub and raise NoMethodError" do
          # Stub a non-existing method
          @klass.xstub({:blurb => 'blah blah'}, :instance => true)
          @get_value["#{@klass}::new.blurb"]

          # Clear stubs without refreshing another process
          CrossStub.clear
          CrossStub.setup(:file => $cache_file)

          # Stub an existing method
          @klass.xstub({:say => 'HELLO'}, :instance => true)
          @get_value["#{@klass}::new.say"]

          # Make sure accessing non-existing method throws error
          should.raise(NoMethodError) { @get_value["#{@klass}::new.blurb"] }
        end

      end

    end
  end

end
