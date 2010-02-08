require 'fileutils'

module Lockfile
  VERSION = '0.0.1'
  
  def with_lock_file(lock_file_path)
    @lock_file_path = lock_file_path
    return false if already_running?
    
    begin
      lock
      yield
      true
    ensure 
      unlock
      remove_instance_variable(:@lock_file_path)
    end
  end
  
  def lock
    open(@lock_file_path, "w+") do |o|
      o.write(Process.pid)
    end  
  end
  
  def unlock
    FileUtils.rm(@lock_file_path, :force => true)
  end
  
  def already_running?
    File.exist?(@lock_file_path)
  end

  def self.force_stop(lock_file_name)
    pid = IO.read(lock_file_name)
    FileUtils.remove_file(lock_file_name, true)
    system("#{property(:killall_cmd)} -9 #{pid}")
  end
end