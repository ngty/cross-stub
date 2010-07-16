require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Creating Instance Stubs' do

  each_cache_store do |store_type|
    %w{current other}.each do |mode|
      %w{AnyInstance#new AnyInstance::Inner#new}.each do |descriptor|

        describe '>> %s process using :%s store (%s)' % [mode, store_type, descriptor] do

          before do
            @descriptor = descriptor
            @klass = klassify(descriptor)
            @store_type = store_type
          end

          behaves_like "has #{mode} process setup"

          should "create with hash argument(s)" do
            @klass.xstub({:bang => 'OOPS', :say => 'HELLO'}, :instance => true)
            @get_value["#{@descriptor}.bang"].should.equal 'OOPS'
            @get_value["#{@descriptor}.say"].should.equal 'HELLO'
          end

          should "create with symbol argument(s)" do
            @klass.xstub(:bang, :instance => true)
            @get_value["#{@descriptor}.bang"].should.equal nil
          end

          should "create with block with no argument" do
            @klass.xstub(:instance => true) do
              def bang ; 'OOPS' ; end
            end
            @get_value["#{@descriptor}.bang"].should.equal 'OOPS'
          end

          should "create with symbol & block with no argument" do
            @klass.xstub(:bang, :instance => true) do
              def say ; 'HELLO' ; end
            end
            @get_value["#{@descriptor}.bang"].should.equal nil
            @get_value["#{@descriptor}.say"].should.equal 'HELLO'
          end

          should "create with hash & block with no argument" do
            @klass.xstub({:bang => 'OOPS'}, :instance => true) do
              def say ; 'HELLO' ; end
            end
            @get_value["#{@descriptor}.bang"].should.equal 'OOPS'
            @get_value["#{@descriptor}.say"].should.equal 'HELLO'
          end

          should "always create the most recent" do
            found, expected = [], ['OOPS', 'OOOPS', 'OOOOPS']
            stub_and_get_value = lambda do |value|
              @klass.xstub({:bang => value}, :instance => true)
              @get_value["#{@descriptor}.bang"]
            end

            found << stub_and_get_value[expected[0]]
            found << stub_and_get_value[expected[1]]

            CrossStub.clear
            CrossStub.setup(cache_store(@store_type))

            found << stub_and_get_value[expected[2]]
            found.should.equal expected
          end

          should "create stub with dependency on other stub" do
            @klass.xstub({:something => 'HELLO'}, :instance => true) do
              def do_action(who, action)
                %\#{who} #{action} #{something}\
              end
            end
            @get_value["#{@descriptor}.do_action.i.say"].should.equal 'i say HELLO'
          end

        end

      end
    end
  end

end
