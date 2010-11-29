require 'helper'

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

  class Lockfile::File < ::File
    #slow open down once to demonstrate race condition
    def self.open(*args)
      unless @no_sleep
        @no_sleep = true
        sleep(1)
      end
      super
    end
  end


  should "not allow to launch other processes while the previous one has lock" do
    Lockfile.ensure_no_lock_file_exists(LOCK_FILE)

    p1 = TestProcess.new
    p2 = TestProcess.new
    p3 = TestProcess.new

    t1 = Thread.new { p1.launch }
    t2 = Thread.new { p2.launch }
    t3 = Thread.new { p3.launch }

    t1.join
    t2.join
    t3.join
    
    #only one should launch
    assert_equal 1, [p1, p2, p3].select{|i| i.launched? }.size
  end
end
