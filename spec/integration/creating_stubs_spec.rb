require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Creating Stubs' do

  behaves_like 'has standard setup'

  %w{current other}.each do |mode|

    behaves_like "has #{mode} process setup"

    %w{AnyClass AnyClass::Inner AnyModule AnyModule::Inner}.each do |klass_or_module|

      before do
        @context = @get_context[klass_or_module]
      end

      it "should create with hash argument(s) for #{klass_or_module} class in #{mode} process" do
        @context.xstub(:say_hello => 'i say hello', :say_world => 'i say world')
        @get_value["#{@context}.say_hello"].should.equal 'i say hello'
        @get_value["#{@context}.say_world"].should.equal 'i say world'
      end

      it "should create with symbol argument(s) for #{klass_or_module} class in #{mode} process" do
        @context.xstub(:say_hello)
        @get_value["#{@context}.say_hello"].should.equal nil
      end

      it "should create with block with no argument for #{klass_or_module} class in #{mode} process" do
        @context.xstub do
          def say_hello ; 'i say hello' ; end
        end
        @get_value["#{@context}.say_hello"].should.equal 'i say hello'
      end

      it "should create with symbol & block with no argument for #{klass_or_module} class in #{mode} process" do
        @context.xstub(:say_hello) do
          def say_world
            'i say world'
          end
        end
        @get_value["#{@context}.say_hello"].should.equal nil
        @get_value["#{@context}.say_world"].should.equal 'i say world'
      end

      it "should create with hash & block with no argument for #{klass_or_module} class in #{mode} process" do
        @context.xstub(:say_hello => 'i say hello') do
          def say_world
            'i say world'
          end
        end
        @get_value["#{@context}.say_hello"].should.equal 'i say hello'
        @get_value["#{@context}.say_world"].should.equal 'i say world'
      end

      it "should always create the most recent for #{klass_or_module} class in #{mode} process" do
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

      it "should create stub with dependency on other stub for #{klass_or_module} class in #{mode} process" do
        @context.xstub(:something => 'hello') do
          def do_action(who, action)
            %\#{who} #{action} #{something}\
          end
        end
        @get_value["#{@context}.do_action.i.say"].should.equal 'i say hello'
      end

      it "should create for method not implemented in ruby for #{klass_or_module} class in #{mode} process" do
        now = Time.now - 365*60*60*24
        Time.xstub(:now => now)
        @get_value['Time.now'].should.equal now
      end

      #    it "should create with block that takes argument(s) for #{mode} process" do
      #      # a, b = 1, 2
      #      # AnyClass.xstub do |a, b|
      #      #   def say_hello
      #      #     "i say #{a+b} hellos"
      #      #   end
      #      # end
      #      # AnyClass.say_hello.should.equal 'i say 3 hellos'
      #    end
      #
      #    it "should create with hash & block that takes argument(s) for #{mode} process" do
      #      # a, b = 1, 2
      #      # AnyClass.xstub(:say_world => 'i say world') do |a, b|
      #      #   def say_hello
      #      #     "i say #{a+b} hellos"
      #      #   end
      #      # end
      #      # AnyClass.say_hello.should.equal 'i say 3 hellos'
      #      # AnyClass.say_world.should.equal 'i say world'
      #    end
    end
  end

end
