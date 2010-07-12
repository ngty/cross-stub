require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Stubbing Error' do

  behaves_like 'has standard setup'

  describe "xstub" do
    it 'should not be raised when stubbing module' do
      should.not.raise(CrossStub::Error) {
        AnyModule.send(:xstub, :say_hello => 'i say hello')
      }
    end

    it 'should not be raised when stubbing class' do
      should.not.raise(CrossStub::Error) {
        AnyClass.send(:xstub, :say_hello => 'i say hello')
      }
    end

    it 'should not be raised when stubbing nested module' do
      should.not.raise(CrossStub::Error) {
        AnyModule::Inner.send(:xstub, :say_hello => 'i say hello')
      }
    end
  end

  describe "xstub_instances" do
    it 'should not be raised when stubbing class' do
      should.not.raise(CrossStub::Error) {
        AnyClass.send(:xstub_instances, :say_hello => 'i say hello')
      }
    end

    it 'should be raised when stubbing instance' do
      should.raise(CrossStub::CannotStubInstanceError) do
        o = AnyClass.new
        o.send(:xstub, :say_hello => 'i say hello')
      end
    end
  end

end
