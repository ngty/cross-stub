require File.join(File.expand_path(File.dirname(__FILE__)), 'shared_spec')

describe 'Clearing Instance Stubs' do

  each_cache_store do |store_type|
    %w{current other}.each do |mode|
      %w{AnyInstance#new AnyInstance::Inner#new}.each do |descriptor|

        describe '>> %s process using :%s store (%s instance)' % [mode, store_type, descriptor] do

          before do
            @descriptor = descriptor
            @klass = klassify(descriptor)
            @instance = @klass.new
            @store_type = store_type
          end

          behaves_like "has #{mode} process setup"

          should "clear hash generated stub and return original value" do
            original_value = @instance.say
            @klass.xstub({:say => 'HELLO'}, :instance => true)
            CrossStub.clear
            @call["#{@descriptor}.say"].should.equal original_value
          end

          should "clear hash generated stub and raise NoMethodError" do
            should.raise(NoMethodError) do
              @klass.xstub({:blurb => 'blah blah'}, :instance => true)
              CrossStub.clear
              @call["#{@descriptor}.blurb"]
            end
          end

          should "clear symbol generated stub and return original value" do
            original_value = @instance.say
            @klass.xstub(:say, :instance => true)
            CrossStub.clear
            @call["#{@descriptor}.say"].should.equal original_value
          end

          should "clear symbol generated stub and raise NoMethodError" do
            should.raise(NoMethodError) do
              @klass.xstub(:blurb, :instance => true)
              CrossStub.clear
              @call["#{@descriptor}.blurb"]
            end
          end

          should "clear block generated stub and return original value" do
            original_value = @instance.say
            @klass.xstub(:instance => true) do
              def say ; 'HELLO' ; end
            end
            CrossStub.clear
            @call["#{@descriptor}.say"].should.equal original_value
          end

          should "clear block generated stub and raise NoMethodError" do
            should.raise(NoMethodError) do
              @klass.xstub(:instance => true) do
                def blurb ; 'blah blah' ; end
              end
              CrossStub.clear
              @call["#{@descriptor}.blurb"]
            end
          end

          should "always clear previously generated stub" do
            original_value = @instance.say

            # Stub an existing method
            @klass.xstub({:say => 'HELLO'}, :instance => true)
            @call["#{@descriptor}.say"]

            # Clear stubs without refreshing another process
            CrossStub.clear
            CrossStub.setup(cache_store(@store_type))

            # Stub a non-existing method
            @klass.xstub({:blurb => 'blah blah'}, :instance => true)
            @call["#{@descriptor}.blurb"]

            # Make sure existing method returns to original method
            @call["#{@descriptor}.say"].should.equal original_value
          end

          should "always clear previously generated stub and raise NoMethodError" do
            # Stub a non-existing method
            @klass.xstub({:blurb => 'blah blah'}, :instance => true)
            @call["#{@descriptor}.blurb"]

            # Clear stubs without refreshing another process
            CrossStub.clear
            CrossStub.setup(cache_store(@store_type))

            # Stub an existing method
            @klass.xstub({:say => 'HELLO'}, :instance => true)
            @call["#{@descriptor}.say"]

            # Make sure accessing non-existing method throws error
            should.raise(NoMethodError) { @call["#{@descriptor}.blurb"] }
          end

          should "clear for method not implemented in ruby and return original value" do
            Time.xstub(:day => 99, :instance => true)
            CrossStub.clear
            value = nil
            should.not.raise(NoMethodError) { value = @call['Time#new.day'] }
            value.should.not.equal 99
          end

        end

      end
    end
  end

end
