require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Creating Stubs' do

  behaves_like 'has standard setup'

  %w{current other}.each do |mode|

    behaves_like "has #{mode} process setup"

    it "should create with hash argument(s) for #{mode} process" do
      AnyClass.xstub(:say_hello => 'i say hello', :say_world => 'i say world')
      @get_value['AnyClass.say_hello'].should.equal 'i say hello'
      @get_value['AnyClass.say_world'].should.equal 'i say world'
    end

    it "should create with symbol argument(s) for #{mode} process" do
      AnyClass.xstub(:say_hello)
      @get_value['AnyClass.say_hello'].should.equal nil
    end

    it "should create with block with no argument for #{mode} process" do
      AnyClass.xstub do
        def say_hello ; 'i say hello' ; end
      end
      @get_value['AnyClass.say_hello'].should.equal 'i say hello'
    end

    it "should create with symbol & block with no argument for #{mode} process" do
      AnyClass.xstub(:say_hello) do
        def say_world
          'i say world'
        end
      end
      @get_value['AnyClass.say_hello'].should.equal nil
      @get_value['AnyClass.say_world'].should.equal 'i say world'
    end

    it "should create with hash & block with no argument for #{mode} process" do
      AnyClass.xstub(:say_hello => 'i say hello') do
        def say_world
          'i say world'
        end
      end
      @get_value['AnyClass.say_hello'].should.equal 'i say hello'
      @get_value['AnyClass.say_world'].should.equal 'i say world'
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
