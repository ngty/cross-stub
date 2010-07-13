require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Creating Instance Stubs' do

  %w{current other}.each do |mode|
    %w{AnyClass AnyClass::Inner}.each do |klass|

      describe '>> %s process (%s instance)' % [mode, klass] do

        behaves_like 'has standard setup'
        behaves_like "has #{mode} process setup"

        before do
          @klass = @get_context[klass]
        end

        should "create with hash argument(s)" do
          @klass.xstub({:say_hello => 'i say hello', :say_world => 'i say world'}, :instance => true)
          @get_value["#{@klass}::new.say_hello"].should.equal 'i say hello'
          @get_value["#{@klass}::new.say_world"].should.equal 'i say world'
        end

        should "create with symbol argument(s)" do
          @klass.xstub(:say_hello, :instance => true)
          @get_value["#{@klass}::new.say_hello"].should.equal nil
        end

        should "create with block with no argument" do
          @klass.xstub(:instance => true) do
            def say_hello ; 'i say hello' ; end
          end
          @get_value["#{@klass}::new.say_hello"].should.equal 'i say hello'
        end

        should "create with symbol & block with no argument" do
          @klass.xstub(:say_hello, :instance => true) do
            def say_world ; 'i say world' ; end
          end
          @get_value["#{@klass}::new.say_hello"].should.equal nil
          @get_value["#{@klass}::new.say_world"].should.equal 'i say world'
        end

        should "create with hash & block with no argument" do
          @klass.xstub({:say_hello => 'i say hello'}, :instance => true) do
            def say_world ; 'i say world' ; end
          end
          @get_value["#{@klass}::new.say_hello"].should.equal 'i say hello'
          @get_value["#{@klass}::new.say_world"].should.equal 'i say world'
        end

        should "always create the most recent" do
          found, expected = [], ['i say hello', 'i say something else', 'i say something else again']
          stub_and_get_value = lambda do |value|
            @klass.xstub({:say_hello => value}, :instance => true)
            @get_value["#{@klass}::new.say_hello"]
          end

          found << stub_and_get_value[expected[0]]
          found << stub_and_get_value[expected[1]]

          CrossStub.clear
          CrossStub.setup(:file => $cache_file)

          found << stub_and_get_value[expected[2]]
          found.should.equal expected
        end

        should "create stub with dependency on other stub" do
          @klass.xstub({:something => 'hello'}, :instance => true) do
            def do_action(who, action) ; %\#{who} #{action} #{something}\ ; end
          end
          @get_value["#{@klass}::new.do_action.i.say"].should.equal 'i say hello'
        end

      end

    end
  end

end
