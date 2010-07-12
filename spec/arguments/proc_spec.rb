require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting methods from proc' do

  before do
    @methods_hash_should_equal = lambda do |expected, block|
      CrossStub::Arguments::Proc.parse(block).should.equal(expected)
    end
  end

  should 'return {} if proc is empty' do
    @methods_hash_should_equal[{}, lambda{}]
  end

  {
#    __LINE__ => lambda{
#      class X ; def m0 ; end ; end
#    },
    __LINE__ => lambda{
      x = 1
    },
#    __LINE__ => lambda{
#      X = 1
#    },
  }.each do |debug, block|
    should "return {} if proc has anything but method definition [##{debug}]" do
      @methods_hash_should_equal[{}, block]
    end
  end

  {
    __LINE__ => lambda{
      def m1 ; true; end
    },
    __LINE__ => lambda{
      class X
        def m0 ; end
        def m1 ; end
      end
      def m1 ; true; end
    },
    __LINE__ => lambda{
      def m1 ; true; end
      class X
        def m0 ; end
        def m1 ; end
      end
    },
    __LINE__ => lambda{
      x = 1
      def m1 ; true; end
    },
    __LINE__ => lambda{
      def m1 ; true; end
      x = 1
    }
  }.each do |debug, block|
    should "return {:m1 => ...} if proc has ONE method [##{debug}]" do
      @methods_hash_should_equal[{
        :m1 => "def m1\n  true\nend"
      }, block]
    end
  end

  {
    __LINE__ => lambda{
      def m1 ; true; end
      def m2 ; false; end
    },
    __LINE__ => lambda{
      class X
        def m0 ; end
        def m1 ; end
      end
      def m1 ; true; end
      def m2 ; false; end
    },
    __LINE__ => lambda{
      def m1 ; true; end
      class X
        def m0 ; end
        def m1 ; end
      end
      def m2 ; false; end
    },
    __LINE__ => lambda{
      x = 1
      def m1 ; true; end
      def m2 ; false; end
    },
    __LINE__ => lambda{
      def m1 ; true; end
      x = 1
      def m2 ; false; end
    },
  }.each do |debug, block|
    should "return {:m1 => ..., :m2 => ...} if proc has MUTLIPLE methods [##{debug}]" do
      @methods_hash_should_equal[{
        :m1 => "def m1\n  true\nend",
        :m2 => "def m2\n  false\nend"
      }, block]
    end
  end

end
