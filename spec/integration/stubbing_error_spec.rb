require File.join(File.dirname(__FILE__), 'shared_spec')

describe 'Stubbing Error' do

  behaves_like 'has standard setup'

  describe ">> xstub" do

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

  describe ">> xstub_instances (alias xstub_instance)" do

    should 'not be raised when stubbing class' do
      [:xstub_instance, :xstub_instances].each do |stub|
        lambda { AnyClass.send(stub, :say_hello => 'i say hello') }.
          should.not.raise(CrossStub::Error)
      end
    end

    should 'not be raised when stubbing nested class' do
      [:xstub_instance, :xstub_instances].each do |stub|
        lambda { AnyClass::Inner.send(stub, :say_hello => 'i say hello') }.
          should.not.raise(CrossStub::Error)
      end
    end

    should 'be raised when stubbing module' do
      [:xstub_instance, :xstub_instances].each do |stub|
        lambda { AnyModule.send(stub, :say_hello => 'i say hello') }.
          should.raise(CrossStub::ModuleCannotBeInstantiatedError)
      end
    end

    should 'be raised when stubbing nested module' do
      [:xstub_instance, :xstub_instances].each do |stub|
        lambda { AnyModule::Inner.send(stub, :say_hello => 'i say hello') }.
          should.raise(CrossStub::ModuleCannotBeInstantiatedError)
      end
    end

    should 'be raised when stubbing instance' do
      [:xstub_instance, :xstub_instances].each do |stub|
        lambda { AnyClass.new.send(stub, :say_hello => 'i say hello') }.
          should.raise(CrossStub::CannotStubInstanceError)
      end
    end

  end

end
