require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Stubbing Error' do

  behaves_like 'has standard setup'

  it 'should not be raised when stubbing module' do
    should.not.raise(CacheStub::Error) {
      AnyModule.cache_stub(:say_hello => 'i say hello')
    }
  end

  it 'should not be raised when stubbing class' do
    should.not.raise(CacheStub::Error) {
      AnyClass.cache_stub(:say_hello => 'i say hello')
    }
  end

  it 'should be raised when stubbing instance' do
    should.raise(CacheStub::CannotStubInstanceError) do
      o = AnyClass.new
      o.cache_stub(:say_hello => 'i say hello')
    end
  end

end
