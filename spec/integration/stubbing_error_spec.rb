require File.join(File.expand_path(File.dirname(__FILE__)), 'shared_spec')

describe 'Stubbing Error' do

  describe ">> xstub (class/module)" do

    before do
      @store_type = :file
    end

    behaves_like 'has standard setup'

    should 'not be raised when stubbing module' do
      lambda { AnyModule.send(:xstub, :bang => 'OOPS') }.
        should.not.raise(CrossStub::Error)
    end

    should 'not be raised when stubbing nested module' do
      lambda { AnyModule::Inner.send(:xstub, :bang => 'OOPS') }.
        should.not.raise(CrossStub::Error)
    end

    should 'not be raised when stubbing class' do
      lambda { AnyClass.send(:xstub, :bang => 'OOPS') }.
        should.not.raise(CrossStub::Error)
    end

    should 'not be raised when stubbing nested class' do
      lambda { AnyClass::Inner.send(:xstub, :bang => 'OOPS') }.
        should.not.raise(CrossStub::Error)
    end

    should 'be raised when stubbing instance' do
      lambda { AnyInstance.new.send(:xstub, :bang => 'OOPS') }.
        should.raise(CrossStub::CannotStubInstanceError)
    end

  end

  describe ">> xstub (instance)" do

    should 'not be raised when stubbing class' do
      lambda { AnyClass.xstub({:bang => 'OOPS'}, :instance => true) }.
        should.not.raise(CrossStub::Error)
    end

    should 'not be raised when stubbing nested class' do
      lambda { AnyClass::Inner.xstub({:bang => 'OOPS'}, :instance => true) }.
        should.not.raise(CrossStub::Error)
    end

    should 'be raised when stubbing module' do
      lambda { AnyModule.xstub({:bang => 'OOPS'}, :instance => true) }.
        should.raise(CrossStub::ModuleCannotBeInstantiatedError)
    end

    should 'be raised when stubbing nested module' do
      lambda { AnyModule::Inner.xstub({:bang => 'OOPS'}, :instance => true) }.
        should.raise(CrossStub::ModuleCannotBeInstantiatedError)
    end

    should 'be raised when stubbing instance' do
      lambda { AnyInstance.new.xstub({:bang => 'OOPS'}, :instance => true) }.
        should.raise(CrossStub::CannotStubInstanceError)
    end

  end

end
