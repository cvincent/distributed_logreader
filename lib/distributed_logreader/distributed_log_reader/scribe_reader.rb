module DLogReader
  class ScribeReader < DistributedLogReader
    attr_accessor :selector, :archiver
    attr_reader :log_reader
    def initialize(filename, backupdir, worker, num_threads = 10)
      super(filename, worker, num_threads)
      self.selector = RotatingLog.new
      self.selector.ignore_conditions << lambda{|x| !x.match(/scribe_stats/).nil?}
      self.archiver = DateDir.new(backupdir)
    end
        
    def log_file
      @log_file ||= begin
        selector.file_to_process(filename)
      end
    end
    
    def post_process
      self.archiver.archive(log_file) unless current?
    end
    
    def current?
      directory = File.dirname(log_file)
      basename = File.basename(directory)
      current_file = Dir[File.join(directory, "*")].detect{|x| x.match(/current/)}
      File.exists?(current_file) && File.identical?(current_file, log_file) 
    end
  end
end