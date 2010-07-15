require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Clearing Stubs' do

  cache_stores.keys.each do |store_type|
    %w{current other}.each do |mode|
      %w{AnyClass AnyClass::Inner AnyModule AnyModule::Inner}.each do |klass_or_module|

        describe '>> %s process using :%s store (%s)' % [mode, store_type, klass_or_module] do

          before do
            @context = get_context(klass_or_module)
            @store_type = store_type
          end

          behaves_like 'has standard setup'
          behaves_like "has #{mode} process setup"

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
            CrossStub.setup(cache_store(@store_type))

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
            CrossStub.setup(cache_store(@store_type))

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

end
