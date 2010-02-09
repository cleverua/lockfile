require File.dirname(__FILE__) + '/test_helper.rb'

class TestLockfile < Test::Unit::TestCase
  LOCK_FILE =  File.dirname(__FILE__) + 'test.lock'

  class TestProcess 
    include Lockfile

    def initialize
      @launched = false
    end

    def launch
      @launched = with_lock_file(LOCK_FILE, false) do
        sleep 2
      end
    end

    def launched?
      @launched
    end
  end

  def test_truth

    p1 = TestProcess.new
    p2 = TestProcess.new
    p3 = TestProcess.new

    t1 = Thread.new { p1.launch }
    t2 = Thread.new { p2.launch }
    t3 = Thread.new { p3.launch }

    t1.join
    t2.join
    t3.join
    
    assert p1.launched? 
    assert !p2.launched?
    assert !p3.launched?

  end
end
