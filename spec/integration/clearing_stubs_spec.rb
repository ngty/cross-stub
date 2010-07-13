require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Clearing Stubs' do

  %w{current other}.each do |mode|
    %w{AnyClass AnyClass::Inner AnyModule AnyModule::Inner}.each do |klass_or_module|

      describe '>> %s process (%s)' % [mode, klass_or_module] do

        behaves_like 'has standard setup'
        behaves_like "has #{mode} process setup"

        before do
          @context = @get_context[klass_or_module]
        end

        should "clear hash generated stub and return original value" do
          original_value = @context.say
          @context.xstub(:say => 'HELLO')
          CrossStub.clear
          @get_value["#{@context}.say"].should.equal original_value
        end

        should "clear hash generated stub and raise NoMethodError" do
          should.raise(NoMethodError) do
            @context.xstub(:bang => 'OOPS')
            CrossStub.clear
            @get_value["#{@context}.bang"]
          end
        end

        should "clear symbol generated stub and return original value" do
          original_value = @context.say
          @context.xstub(:say)
          CrossStub.clear
          @get_value["#{@context}.say"].should.equal original_value
        end

        should "clear symbol generated stub and raise NoMethodError" do
          should.raise(NoMethodError) do
            @context.xstub(:bang)
            CrossStub.clear
            @get_value["#{@context}.bang"]
          end
        end

        should "clear block generated stub and return original value" do
          original_value = @context.say
          @context.xstub do
            def say ; 'HELLO' ; end
          end
          CrossStub.clear
          @get_value["#{@context}.say"].should.equal original_value
        end

        should "clear block generated stub and raise NoMethodError" do
          should.raise(NoMethodError) do
            @context.xstub do
              def bang ; 'OOPS' ; end
            end
            CrossStub.clear
            @get_value["#{@context}.bang"]
          end
        end

        should "always clear previously generated stub" do
          original_value = @context.say

          # Stub an existing method
          @context.xstub(:say => 'HELLO')
          @get_value["#{@context}.say"]

          # Clear stubs without refreshing another process
          CrossStub.clear
          CrossStub.setup(:file => $cache_file)

          # Stub a non-existing method
          @context.xstub(:bang => 'OOPS')
          @get_value["#{@context}.bang"]

          # Make sure existing method returns to original method
          @get_value["#{@context}.say"].should.equal original_value
        end

        should "always clear previously generated stub and raise NoMethodError" do
          # Stub a non-existing method
          @context.xstub(:bang => 'OOPS')
          @get_value["#{@context}.bang"]

          # Clear stubs without refreshing another process
          CrossStub.clear
          CrossStub.setup(:file => $cache_file)

          # Stub an existing method
          @context.xstub(:say => 'HELLO')
          @get_value["#{@context}.say"]

          # Make sure accessing non-existing method throws error
          should.raise(NoMethodError) { @get_value["#{@context}.bang"] }
        end

        should "clear for method not implemented in ruby and return original value" do
          Time.xstub(:now => 'abc')
          CrossStub.clear
          value = nil
          should.not.raise(NoMethodError) { value = @get_value['Time.now'] }
          value.should.not.equal 'abc'
        end

      end

    end
  end

end
