require 'fileutils'

module Lockfile
  VERSION = '0.0.2'

  def self.ensure_no_lock_file_exists(lock_file_name)
    FileUtils.remove_file(lock_file_name, true)
  end
  
  def with_lock_file(lock_file_path, write_pid = true)
    return false if already_running?(lock_file_path)
    
    begin
      obtain_lock(lock_file_path, write_pid)
      yield
    ensure 
      release_lock(lock_file_path)
    end
  end
  
  private

  def obtain_lock(lf, write_pid)
    open(lf, "w+") do |o|
      o.write(Process.pid) if write_pid
    end  
  end
  
  def release_lock(lf)
    FileUtils.rm(lf, :force => true)
  end
  
  def already_running?(lock_file_path)
    return File.exist?(lock_file_path)
  end

  
end
