require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Clearing Stubs' do

  behaves_like 'has standard setup'

  # %w{current other}.each do |mode|
  %w{current}.each do |mode|

    it "should clear hash generated stub and return original value for #{mode} process" do
      original_value = AnyClass.say_world
      AnyClass.cache_stub(:say_world => 'i say world')
      CacheStub.clear
      AnyClass.say_world.should.equal original_value
    end

    it "should clear hash generated stub and raise UndefinedMethod error for #{mode} process" do
      should.raise(NoMethodError) do
        AnyClass.cache_stub(:say_hello => 'i say hello')
        CacheStub.clear
        AnyClass.say_hello
      end
    end

    it "should clear symbol generated stub and return original value for #{mode} process" do
      original_value = AnyClass.say_world
      AnyClass.cache_stub(:say_world)
      CacheStub.clear
      AnyClass.say_world.should.equal original_value
    end

    it "should clear symbol generated stub and raise UndefinedMethod error for #{mode} process" do
      should.raise(NoMethodError) do
        AnyClass.cache_stub(:say_hello)
        CacheStub.clear
        AnyClass.say_hello
      end
    end

    it "should clear block generated stub and return original value for #{mode} process" do
      original_value = AnyClass.say_world
      AnyClass.cache_stub do
        def say_world ; 'i say world' ; end
      end
      CacheStub.clear
      AnyClass.say_world.should.equal original_value
    end

    it "should clear block generated stub and raise UndefinedMethod error for #{mode} process" do
      should.raise(NoMethodError) do
        AnyClass.cache_stub do
          def say_hello ; 'i say hello' ; end
        end
        CacheStub.clear
        AnyClass.say_hello
      end
    end

  end

end
