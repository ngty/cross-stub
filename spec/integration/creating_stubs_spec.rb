require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Creating Stubs' do

  %w{current other}.each do |mode|
    %w{AnyClass AnyClass::Inner AnyModule AnyModule::Inner}.each do |klass_or_module|

      describe '>> %s process (%s)' % [mode, klass_or_module] do

        behaves_like 'has standard setup'
        behaves_like "has #{mode} process setup"

        before do
          @context = @get_context[klass_or_module]
        end

        should "create with hash argument(s)" do
          @context.xstub(:bang => 'OOPS', :say => 'HELLO')
          @get_value["#{@context}.bang"].should.equal 'OOPS'
          @get_value["#{@context}.say"].should.equal 'HELLO'
        end

        should "create with symbol argument(s)" do
          @context.xstub(:bang)
          @get_value["#{@context}.bang"].should.equal nil
        end

        should "create with block with no argument" do
          @context.xstub do
            def bang ; 'OOPS' ; end
          end
          @get_value["#{@context}.bang"].should.equal 'OOPS'
        end

        should "create with symbol & block with no argument" do
          @context.xstub(:bang) do
            def say
              'HELLO'
            end
          end
          @get_value["#{@context}.bang"].should.equal nil
          @get_value["#{@context}.say"].should.equal 'HELLO'
        end

        should "create with hash & block with no argument" do
          @context.xstub(:bang => 'OOPS') do
            def say
              'HELLO'
            end
          end
          @get_value["#{@context}.bang"].should.equal 'OOPS'
          @get_value["#{@context}.say"].should.equal 'HELLO'
        end

        should "always create the most recent" do
          found, expected = [], ['OOPS', 'OOOPS', 'OOOOPS']
          stub_and_get_value = lambda do |value|
            @context.xstub(:bang => value)
            @get_value["#{@context}.bang"]
          end

          found << stub_and_get_value[expected[0]]
          found << stub_and_get_value[expected[1]]

          CrossStub.clear
          CrossStub.setup(:file => $cache_file)

          found << stub_and_get_value[expected[2]]
          found.should.equal expected
        end

        should "create stub with dependency on other stub" do
          @context.xstub(:something => 'HELLO') do
            def do_action(who, action)
              %\#{who} #{action} #{something}\
            end
          end
          @get_value["#{@context}.do_action.i.say"].should.equal 'i say HELLO'
        end

        should "create for method not implemented in ruby" do
          now = Time.now - 365*60*60*24
          Time.xstub(:now => now)
          @get_value['Time.now'].should.equal now
        end

      end

    end
  end

end
