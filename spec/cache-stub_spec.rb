require File.dirname(__FILE__) + '/spec_helper.rb'

class AnyClass
  def self.say_world
    'u say world'
  end
end

class AnyModule
  def self.say_world
    'u say world'
  end
end

describe 'cache_stub' do

  before do
    CacheStub.setup(:file => '/tmp/cachemock.cache')
  end

  after do
    CacheStub.clear
  end

  it 'should set stub for module' do
    should.not.raise(CacheStub::Error) {
      AnyModule.cache_stub(:say_hello => 'i say hello')
    }
  end

  it 'should set stub for class' do
    should.not.raise(CacheStub::Error) {
      AnyClass.cache_stub(:say_hello => 'i say hello')
    }
  end

  it 'should not set stub for instance' do
    should.raise(CacheStub::CannotStubInstanceError) do
      o = AnyClass.new
      o.cache_stub(:say_hello => 'i say hello')
    end
  end

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

    it "should clear closure generated stub and return original value for #{mode} process" do
      original_value = AnyClass.say_world
      AnyClass.cache_stub do
        def say_world ; 'i say world' ; end
      end
      CacheStub.clear
      AnyClass.say_world.should.equal original_value
    end

    it "should clear closure generated stub and raise UndefinedMethod error for #{mode} process" do
      should.raise(NoMethodError) do
        AnyClass.cache_stub do
          def say_hello ; 'i say hello' ; end
        end
        CacheStub.clear
        AnyClass.say_hello
      end
    end

    it "should create stub with hash argument for #{mode} process" do
      AnyClass.cache_stub(:say_hello => 'i say hello', :say_world => 'i say world')
      AnyClass.say_hello.should.equal 'i say hello'
      AnyClass.say_world.should.equal 'i say world'
    end

    it "should create stub without argument for #{mode} process" do
      AnyClass.cache_stub(:say_hello)
      AnyClass.say_hello.should.equal nil
    end

    it "should create stub with block without arguments for #{mode} process" do
      AnyClass.cache_stub do
        def say_hello ; 'i say hello' ; end
      end
      AnyClass.say_hello.should.equal 'i say hello'
    end

#    it "should create stub with block that takes arguments for #{mode} process" do
#      # a, b = 1, 2
#      # AnyClass.cache_stub do |a, b|
#      #   def say_hello
#      #     "i say #{a+b} hellos"
#      #   end
#      # end
#      # AnyClass.say_hello.should.equal 'i say 3 hellos'
#    end
#
#    it "should create stub with hash & block with no arguments for #{mode} process" do
#      # AnyClass.cache_stub(:say_hello => 'i say hello') do
#      #   def say_world
#      #     'i say world'
#      #   end
#      # end
#      # AnyClass.say_hello.should.equal 'i say hello'
#      # AnyClass.say_world.should.equal 'i say world'
#    end
#
#    it "should create stub with hash & block that takes arguments for #{mode} process" do
#      # a, b = 1, 2
#      # AnyClass.cache_stub(:say_world => 'i say world') do |a, b|
#      #   def say_hello
#      #     "i say #{a+b} hellos"
#      #   end
#      # end
#      # AnyClass.say_hello.should.equal 'i say 3 hellos'
#      # AnyClass.say_world.should.equal 'i say world'
#    end

  end

end
