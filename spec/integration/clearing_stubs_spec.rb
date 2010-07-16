require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Clearing Stubs' do

  each_cache_store do |store_type|
    %w{current other}.each do |mode|
      %w{AnyClass AnyClass::Inner AnyModule AnyModule::Inner}.each do |descriptor|

        describe '>> %s process using :%s store (%s)' % [mode, store_type, descriptor] do

          before do
            @descriptor = descriptor
            @klass = klassify(descriptor)
            @store_type = store_type
          end

          behaves_like "has #{mode} process setup"

          should "clear hash generated stub and return original value" do
            original_value = @klass.say
            @klass.xstub(:say => 'HELLO')
            CrossStub.clear
            @get_value["#{@descriptor}.say"].should.equal original_value
          end

          should "clear hash generated stub and raise NoMethodError" do
            should.raise(NoMethodError) do
              @klass.xstub(:bang => 'OOPS')
              CrossStub.clear
              @get_value["#{@descriptor}.bang"]
            end
          end

          should "clear symbol generated stub and return original value" do
            original_value = @klass.say
            @klass.xstub(:say)
            CrossStub.clear
            @get_value["#{@descriptor}.say"].should.equal original_value
          end

          should "clear symbol generated stub and raise NoMethodError" do
            should.raise(NoMethodError) do
              @klass.xstub(:bang)
              CrossStub.clear
              @get_value["#{@descriptor}.bang"]
            end
          end

          should "clear block generated stub and return original value" do
            original_value = @klass.say
            @klass.xstub do
              def say ; 'HELLO' ; end
            end
            CrossStub.clear
            @get_value["#{@descriptor}.say"].should.equal original_value
          end

          should "clear block generated stub and raise NoMethodError" do
            should.raise(NoMethodError) do
              @klass.xstub do
                def bang ; 'OOPS' ; end
              end
              CrossStub.clear
              @get_value["#{@descriptor}.bang"]
            end
          end

          should "always clear previously generated stub" do
            original_value = @klass.say

            # Stub an existing method
            @klass.xstub(:say => 'HELLO')
            @get_value["#{@descriptor}.say"]

            # Clear stubs without refreshing another process
            CrossStub.clear
            CrossStub.setup(cache_store(@store_type))

            # Stub a non-existing method
            @klass.xstub(:bang => 'OOPS')
            @get_value["#{@descriptor}.bang"]

            # Make sure existing method returns to original method
            @get_value["#{@descriptor}.say"].should.equal original_value
          end

          should "always clear previously generated stub and raise NoMethodError" do
            # Stub a non-existing method
            @klass.xstub(:bang => 'OOPS')
            @get_value["#{@descriptor}.bang"]

            # Clear stubs without refreshing another process
            CrossStub.clear
            CrossStub.setup(cache_store(@store_type))

            # Stub an existing method
            @klass.xstub(:say => 'HELLO')
            @get_value["#{@descriptor}.say"]

            # Make sure accessing non-existing method throws error
            should.raise(NoMethodError) { @get_value["#{@descriptor}.bang"] }
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
