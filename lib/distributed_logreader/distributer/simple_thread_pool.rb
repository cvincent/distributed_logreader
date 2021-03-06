require 'thread'

module DLogReader
  class SimpleThreadPool
    attr_accessor :num_threads, :worker, :thread_pool, :queue, :max_queue_size
    def initialize(worker, num_threads = 5)
      self.worker = worker
      self.num_threads = num_threads
      self.queue = Queue.new
      self.max_queue_size = 100
      num_threads.times do 
        create_thread
      end
    end
    
    def process(line)
      while(queue.size > self.max_queue_size)
        sleep(0.01)
      end
      self.queue << line
    end
    
    def join
      while(queue.size > 0)
        sleep 0.1
      end
    end
    
protected    
    def create_thread
      Thread.new do
        loop do
          line = self.queue.pop
          begin
            self.worker.call(line)
          rescue Exception => e
            $dlog_logger.warn("Exception in processing thread #{line} -- #{e.message}")
          end
        end
      end
    end
  end
end