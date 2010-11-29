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
      puts "hi"
      unless @no_sleep
        @no_sleep = true
        sleep(1)
      end
      super
    end
  end


  should "not allow to launch other processes while the previous one has lock" do
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
