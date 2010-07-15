require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Creating Instance Stubs' do

  cache_stores.keys.each do |store_type|
    %w{current other}.each do |mode|
      %w{AnyInstance AnyInstance::Inner}.each do |klass|

        describe '>> %s process using :%s store (%s)' % [mode, store_type, klass] do

          before do
            @context = get_context(klass)
            @store_type = store_type
          end

          behaves_like 'has standard setup'
          behaves_like "has #{mode} process setup"

          should "create with hash argument(s)" do
            @context.xstub({:bang => 'OOPS', :say => 'HELLO'}, :instance => true)
            @get_value["#{@context}::new.bang"].should.equal 'OOPS'
            @get_value["#{@context}::new.say"].should.equal 'HELLO'
          end

          should "create with symbol argument(s)" do
            @context.xstub(:bang, :instance => true)
            @get_value["#{@context}::new.bang"].should.equal nil
          end

          should "create with block with no argument" do
            @context.xstub(:instance => true) do
              def bang ; 'OOPS' ; end
            end
            @get_value["#{@context}::new.bang"].should.equal 'OOPS'
          end

          should "create with symbol & block with no argument" do
            @context.xstub(:bang, :instance => true) do
              def say ; 'HELLO' ; end
            end
            @get_value["#{@context}::new.bang"].should.equal nil
            @get_value["#{@context}::new.say"].should.equal 'HELLO'
          end

          should "create with hash & block with no argument" do
            @context.xstub({:bang => 'OOPS'}, :instance => true) do
              def say ; 'HELLO' ; end
            end
            @get_value["#{@context}::new.bang"].should.equal 'OOPS'
            @get_value["#{@context}::new.say"].should.equal 'HELLO'
          end

          should "always create the most recent" do
            found, expected = [], ['OOPS', 'OOOPS', 'OOOOPS']
            stub_and_get_value = lambda do |value|
              @context.xstub({:bang => value}, :instance => true)
              @get_value["#{@context}::new.bang"]
            end

            found << stub_and_get_value[expected[0]]
            found << stub_and_get_value[expected[1]]

            CrossStub.clear
            CrossStub.setup(cache_store(@store_type))

            found << stub_and_get_value[expected[2]]
            found.should.equal expected
          end

          should "create stub with dependency on other stub" do
            @context.xstub({:something => 'HELLO'}, :instance => true) do
              def do_action(who, action)
                %\#{who} #{action} #{something}\
              end
            end
            @get_value["#{@context}::new.do_action.i.say"].should.equal 'i say HELLO'
          end

        end

      end
    end
  end

end
