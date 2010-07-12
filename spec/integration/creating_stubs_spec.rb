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
          @context.xstub(:say_hello => 'i say hello', :say_world => 'i say world')
          @get_value["#{@context}.say_hello"].should.equal 'i say hello'
          @get_value["#{@context}.say_world"].should.equal 'i say world'
        end

        should "create with symbol argument(s)" do
          @context.xstub(:say_hello)
          @get_value["#{@context}.say_hello"].should.equal nil
        end

        should "create with block with no argument" do
          @context.xstub do
            def say_hello ; 'i say hello' ; end
          end
          @get_value["#{@context}.say_hello"].should.equal 'i say hello'
        end

        should "create with symbol & block with no argument" do
          @context.xstub(:say_hello) do
            def say_world
              'i say world'
            end
          end
          @get_value["#{@context}.say_hello"].should.equal nil
          @get_value["#{@context}.say_world"].should.equal 'i say world'
        end

        should "create with hash & block with no argument" do
          @context.xstub(:say_hello => 'i say hello') do
            def say_world
              'i say world'
            end
          end
          @get_value["#{@context}.say_hello"].should.equal 'i say hello'
          @get_value["#{@context}.say_world"].should.equal 'i say world'
        end

        should "always create the most recent" do
          found, expected = [], ['i say hello', 'i say something else', 'i say something else again']
          stub_and_get_value = lambda do |value|
            @context.xstub(:say_hello => value)
            @get_value["#{@context}.say_hello"]
          end

          found << stub_and_get_value[expected[0]]
          found << stub_and_get_value[expected[1]]

          CrossStub.clear
          CrossStub.setup(:file => $cache_file)

          found << stub_and_get_value[expected[2]]
          found.should.equal expected
        end

        should "create stub with dependency on other stub" do
          @context.xstub(:something => 'hello') do
            def do_action(who, action)
              %\#{who} #{action} #{something}\
            end
          end
          @get_value["#{@context}.do_action.i.say"].should.equal 'i say hello'
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
