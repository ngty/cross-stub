require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting methods from proc' do

  extract = CrossStub::Arguments::Proc.method(:parse)

  describe '>> proc with single method (wo argument)' do

    expected = {:bang => "def bang\n  \"oops\"\nend"}

    {
    # ////////////////////////////////////////////////////////////////////////
    # >> Always newlinling
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do
          def bang
            'oops'
          end
        end
      ),
      __LINE__ => (
        lambda {
          def bang
            'oops'
          end
        }
      ),
      __LINE__ => (
        proc do
          def bang
            'oops'
          end
        end
      ),
      __LINE__ => (
        proc {
          def bang
            'oops'
          end
        }
      ),
      __LINE__ => (
        Proc.new do
          def bang
            'oops'
          end
        end
      ),
      __LINE__ => (
        Proc.new {
          def bang
            'oops'
          end
        }
      ),
    # ////////////////////////////////////////////////////////////////////////
    # >> Partial newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do
          def bang ; 'oops' ; end
        end
      ),
      __LINE__ => (
        lambda {
          def bang ; 'oops' ; end
        }
      ),
      __LINE__ => (
        proc do
          def bang ; 'oops' ; end
        end
      ),
      __LINE__ => (
        proc {
          def bang ; 'oops' ; end
        }
      ),
      __LINE__ => (
        Proc.new do
          def bang ; 'oops' ; end
        end
      ),
      __LINE__ => (
        Proc.new {
          def bang ; 'oops' ; end
        }
      ),
    # ////////////////////////////////////////////////////////////////////////
    # >> No newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do def bang ; 'oops' ; end end
      ),
      __LINE__ => (
        lambda { def bang ; 'oops' ; end }
      ),
      __LINE__ => (
        proc do def bang ; 'oops' ; end end
      ),
      __LINE__ => (
        proc { def bang ; 'oops' ; end }
      ),
      __LINE__ => (
        Proc.new do def bang ; 'oops' ; end end
      ),
      __LINE__ => (
        Proc.new { def bang ; 'oops' ; end }
      ),
    }.each do |debug, block|
      should "handle proc as variable [##{debug}]" do
        extract.call(&block).should.equal(expected)
      end
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def bang
          'oops'
        end
      end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def bang ; 'oops' ; end
      end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do def bang ; 'oops' ; end ; end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def bang
          'oops'
        end
      end.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call {
        def bang
          'oops'
        end
      }.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call {
        def bang ; 'oops' ; end
      }.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call { def bang ; 'oops' ; end }.should.equal(expected)
    end

  end

  describe '>> proc with single method (w argument)' do

    expected = {:shout => "def shout(wat)\n  wat\nend"}

    {
    # ////////////////////////////////////////////////////////////////////////
    # >> Always newlinling
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do
          def shout(wat)
            wat
          end
        end
      ),
      __LINE__ => (
        lambda {
          def shout(wat)
            wat
          end
        }
      ),
      __LINE__ => (
        proc do
          def shout(wat)
            wat
          end
        end
      ),
      __LINE__ => (
        proc {
          def shout(wat)
            wat
          end
        }
      ),
      __LINE__ => (
        Proc.new do
          def shout(wat)
            wat
          end
        end
      ),
      __LINE__ => (
        Proc.new {
          def shout(wat)
            wat
          end
        }
      ),
    # ////////////////////////////////////////////////////////////////////////
    # >> Partial newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do
          def shout(wat) ; wat ; end
        end
      ),
      __LINE__ => (
        lambda {
          def shout(wat) ; wat ; end
        }
      ),
      __LINE__ => (
        proc do
          def shout(wat) ; wat ; end
        end
      ),
      __LINE__ => (
        proc {
          def shout(wat) ; wat ; end
        }
      ),
      __LINE__ => (
        Proc.new do
          def shout(wat) ; wat ; end
        end
      ),
      __LINE__ => (
        Proc.new {
          def shout(wat) ; wat ; end
        }
      ),
    # ////////////////////////////////////////////////////////////////////////
    # >> No newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do def shout(wat) ; wat ; end end
      ),
      __LINE__ => (
        lambda { def shout(wat) ; wat ; end }
      ),
      __LINE__ => (
        proc do def shout(wat) ; wat ; end end
      ),
      __LINE__ => (
        proc { def shout(wat) ; wat ; end }
      ),
      __LINE__ => (
        Proc.new do def shout(wat) ; wat ; end end
      ),
      __LINE__ => (
        Proc.new { def shout(wat) ; wat ; end }
      ),
    }.each do |debug, block|
      should "handle proc as variable [##{debug}]" do
        extract.call(&block).should.equal(expected)
      end
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def shout(wat)
          wat
        end
      end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def shout(wat) ; wat ; end
      end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do def shout(wat) ; wat ; end end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def shout(wat)
          wat
        end
      end.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call {
        def shout(wat)
          wat
        end
      }.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call {
        def shout(wat) ; wat ; end
      }.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call { def shout(wat) ; wat ; end }.should.equal(expected)
    end

  end

  describe '>> proc with multiple methods (wo argument)' do

    expected = {
      :bang => "def bang\n  \"oops\"\nend",
      :shout => "def shout\n  \"hello\"\nend"
    }

    {
    # ////////////////////////////////////////////////////////////////////////
    # >> Always newlinling
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do
          def bang
            'oops'
          end
          def shout
            'hello'
          end
        end
      ),
      __LINE__ => (
        lambda {
          def bang
            'oops'
          end
          def shout
            'hello'
          end
        }
      ),
      __LINE__ => (
        proc do
          def bang
            'oops'
          end
          def shout
            'hello'
          end
        end
      ),
      __LINE__ => (
        proc {
          def bang
            'oops'
          end
          def shout
            'hello'
          end
        }
      ),
      __LINE__ => (
        Proc.new do
          def bang
            'oops'
          end
          def shout
            'hello'
          end
        end
      ),
      __LINE__ => (
        Proc.new {
          def bang
            'oops'
          end
          def shout
            'hello'
          end
        }
      ),
    # ////////////////////////////////////////////////////////////////////////
    # >> Partial newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do
          def bang ; 'oops' ; end
          def shout ; 'hello' ; end
        end
      ),
      __LINE__ => (
        lambda {
          def bang ; 'oops' ; end
          def shout ; 'hello' ; end
        }
      ),
      __LINE__ => (
        proc do
          def bang ; 'oops' ; end
          def shout ; 'hello' ; end
        end
      ),
      __LINE__ => (
        proc {
          def bang ; 'oops' ; end
          def shout ; 'hello' ; end
        }
      ),
      __LINE__ => (
        Proc.new do
          def bang ; 'oops' ; end
          def shout ; 'hello' ; end
        end
      ),
      __LINE__ => (
        Proc.new {
          def bang ; 'oops' ; end
          def shout ; 'hello' ; end
        }
      ),
    # ////////////////////////////////////////////////////////////////////////
    # >> No newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do def bang ; 'oops' ; end ; def shout ; 'hello' ; end end
      ),
      __LINE__ => (
        lambda { def bang ; 'oops' ; end ; def shout ; 'hello' ; end }
      ),
      __LINE__ => (
        proc do def bang ; 'oops' ; end ; def shout ; 'hello' ; end end
      ),
      __LINE__ => (
        proc { def bang ; 'oops' ; end ; def shout ; 'hello' ; end }
      ),
      __LINE__ => (
        Proc.new do def bang ; 'oops' ; end ; def shout ; 'hello' ; end end
      ),
      __LINE__ => (
        Proc.new { def bang ; 'oops' ; end ; def shout ; 'hello' ; end }
      ),
    }.each do |debug, block|
      should "handle proc as variable [##{debug}]" do
        extract.call(&block).should.equal(expected)
      end
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def bang
          'oops'
        end
        def shout
          'hello'
        end
      end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def bang ; 'oops' ; end
        def shout ; 'hello' ; end
      end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do def bang ; 'oops' ; end ; def shout ; 'hello' ; end end.
        should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call {
        def bang
          'oops'
        end
        def shout
          'hello'
        end
      }.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call {
        def bang ; 'oops' ; end
        def shout ; 'hello' ; end
      }.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call { def bang ; 'oops' ; end ; def shout ; 'hello' ; end }.
        should.equal(expected)
    end

  end

  describe '>> proc with multiple methods (w argument)' do

    expected = {
      :bang => "def bang(wat)\n  wat\nend",
      :shout => "def shout(wat)\n  wat\nend"
    }

    {
    # ////////////////////////////////////////////////////////////////////////
    # >> Always newlinling
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do
          def bang(wat)
            wat
          end
          def shout(wat)
            wat
          end
        end
      ),
      __LINE__ => (
        lambda {
          def bang(wat)
            wat
          end
          def shout(wat)
            wat
          end
        }
      ),
      __LINE__ => (
        proc do
          def bang(wat)
            wat
          end
          def shout(wat)
            wat
          end
        end
      ),
      __LINE__ => (
        proc {
          def bang(wat)
            wat
          end
          def shout(wat)
            wat
          end
        }
      ),
      __LINE__ => (
        Proc.new do
          def bang(wat)
            wat
          end
          def shout(wat)
            wat
          end
        end
      ),
      __LINE__ => (
        Proc.new {
          def bang(wat)
            wat
          end
          def shout(wat)
            wat
          end
        }
      ),
    # ////////////////////////////////////////////////////////////////////////
    # >> Partial newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do
          def bang(wat) ; wat ; end
          def shout(wat) ; wat ; end
        end
      ),
      __LINE__ => (
        lambda {
          def bang(wat) ; wat ; end
          def shout(wat) ; wat ; end
        }
      ),
      __LINE__ => (
        proc do
          def bang(wat) ; wat ; end
          def shout(wat) ; wat ; end
        end
      ),
      __LINE__ => (
        proc {
          def bang(wat) ; wat ; end
          def shout(wat) ; wat ; end
        }
      ),
      __LINE__ => (
        Proc.new do
          def bang(wat) ; wat ; end
          def shout(wat) ; wat ; end
        end
      ),
      __LINE__ => (
        Proc.new {
          def bang(wat) ; wat ; end
          def shout(wat) ; wat ; end
        }
      ),
    # ////////////////////////////////////////////////////////////////////////
    # >> No newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ => (
        lambda do def bang(wat) ; wat ; end ; def shout(wat) ; wat ; end end
      ),
      __LINE__ => (
        lambda { def bang(wat) ; wat ; end ; def shout(wat) ; wat ; end }
      ),
      __LINE__ => (
        proc do def bang(wat) ; wat ; end ; def shout(wat) ; wat ; end end
      ),
      __LINE__ => (
        proc { def bang(wat) ; wat ; end ; def shout(wat) ; wat ; end }
      ),
      __LINE__ => (
        Proc.new do def bang(wat) ; wat ; end ; def shout(wat) ; wat ; end end
      ),
      __LINE__ => (
        Proc.new { def bang(wat) ; wat ; end ; def shout(wat) ; wat ; end }
      ),
    }.each do |debug, block|
      should "handle proc as variable [##{debug}]" do
        extract.call(&block).should.equal(expected)
      end
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def bang(wat)
          wat
        end
        def shout(wat)
          wat
        end
      end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do
        def bang(wat) ; wat ; end
        def shout(wat) ; wat ; end
      end.should.equal(expected)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      extract.call do def bang(wat) ; wat ; end ; def shout(wat) ; wat ; end end.
        should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call {
        def bang(wat)
          wat
        end
        def shout(wat)
          wat
        end
      }.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call {
        def bang(wat) ; wat ; end
        def shout(wat) ; wat ; end
      }.should.equal(expected)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      extract.call { def bang(wat) ; wat ; end ; def shout(wat) ; wat ; end }.
        should.equal(expected)
    end

  end

end
