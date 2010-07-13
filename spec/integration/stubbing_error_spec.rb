require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Stubbing Error' do

  behaves_like 'has standard setup'

  describe ">> xstub (class/module)" do

    should 'not be raised when stubbing module' do
      lambda { AnyModule.send(:xstub, :say_hello => 'i say hello') }.
        should.not.raise(CrossStub::Error)
    end

    should 'not be raised when stubbing nested module' do
      lambda { AnyModule::Inner.send(:xstub, :say_hello => 'i say hello') }.
        should.not.raise(CrossStub::Error)
    end

    should 'not be raised when stubbing class' do
      lambda { AnyClass.send(:xstub, :say_hello => 'i say hello') }.
        should.not.raise(CrossStub::Error)
    end

    should 'not be raised when stubbing nested class' do
      lambda { AnyClass::Inner.send(:xstub, :say_hello => 'i say hello') }.
        should.not.raise(CrossStub::Error)
    end

    should 'be raised when stubbing instance' do
      lambda { AnyClass.new.send(:xstub, :say_hello => 'i say hello') }.
        should.raise(CrossStub::CannotStubInstanceError)
    end

  end

  describe ">> xstub (instance)" do

    should 'not be raised when stubbing class' do
      lambda { AnyClass.xstub({:say_hello => 'i say hello'}, :instance => true) }.
        should.not.raise(CrossStub::Error)
    end

    should 'not be raised when stubbing nested class' do
      lambda { AnyClass::Inner.xstub({:say_hello => 'i say hello'}, :instance => true) }.
        should.not.raise(CrossStub::Error)
    end

    should 'be raised when stubbing module' do
      lambda { AnyModule.xstub({:say_hello => 'i say hello'}, :instance => true) }.
        should.raise(CrossStub::ModuleCannotBeInstantiatedError)
    end

    should 'be raised when stubbing nested module' do
      lambda { AnyModule::Inner.xstub({:say_hello => 'i say hello'}, :instance => true) }.
        should.raise(CrossStub::ModuleCannotBeInstantiatedError)
    end

    should 'be raised when stubbing instance' do
      lambda { AnyClass.new.xstub({:say_hello => 'i say hello'}, :instance => true) }.
        should.raise(CrossStub::CannotStubInstanceError)
    end

  end

end
