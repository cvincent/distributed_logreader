module DLogReader
  # This class chooses the oldest log file in the directory that matches the
  # input filename.  This should work with a variety of log rotating schemes:
  # including copytruncate and date suffix.
  class RotatingLog < Selector
    
    attr_accessor :ignore_conditions
    
    def initialize
      self.ignore_conditions = []
      self.ignore_conditions << lambda{|x| symlink_file_in_dir?(x)}
      # self.ignore_conditions << lambda{|x| true}
    end
  
    def file_to_process(file_or_dir)
      if File.directory?(file_or_dir)
        directory = file_or_dir
        basename = '/'
      else
        directory = File.dirname(file_or_dir)
        basename = File.basename(file_or_dir)
      end    
      oldest_logfile(directory, basename)
    end

protected

    def oldest_logfile(directory, basename)
      file_list = Dir[File.join(directory, "#{basename}*")]
      file_list.reject!{|x| reject?(x)}
      file = file_list.size > 0 ? file_list.sort_by{|a| File.new(a).mtime}.first : nil
    end
    
    def reject?(filename)
      self.ignore_conditions.inject(false){|candidate, condition| candidate || condition.call(filename)}
    end
    
    # returns true if filename is a symlink and its referring to a file already inside the current directory
    def symlink_file_in_dir?(filename)
      File.symlink?(filename) && File.dirname(File.readlink(filename)) == File.dirname(filename)
    end
  end
end