### 
 # Created by anthony on 27.09.16.
 ## 

require 'thread'


Thread.abort_on_exception = true


class ThreadPool
	def initialize(cpu_count=2)
		@@work_queue = Queue.new
		@@thread_count = cpu_count * 2
	end

	def run
		(0..@@thread_count).map do
			Thread.new {
				until @@work_queue.empty?
					client = @@work_queue.pop(true) rescue nil
	  			if client
	  				main_handler(client)
	  			end
	  		end
		  }.join
		end
	end

	def put_client(client)
		@@work_queue << client
	end
end
