### 
 # Created by anthony on 25.09.16.
 ## 

require 'socket'
require 'concurrent'

require './config'
require './handlers'
require './optparse'

interrupt = false

options = get_options()

host = HOST
if options.has_key?(:host)
	host = options[:host]
end

port = PORT
if options.has_key?(:port)
	port = options[:port]
end

if options.has_key?(:rdir)
	DOCUMENT_ROOT = options[:rdir]
end

ncpu = NCPU
if options.has_key?(:ncpu)
	ncpu = options[:ncpu].to_i
end
ncpu = [ncpu / 2, Concurrent.processor_count].min

work_queue = Queue.new
server = TCPServer.new host, port
puts "Listen #{host} on #{port}..."


ncpu.times do
  fork
end


# pool = Concurrent::CachedThreadPool.new(
#   :min_threads => [2, ncpu * 2 + 1].max,
#   :max_threads => [2, ncpu * 2 + 1].max,
#   :max_queue   => [2, ncpu * 2 + 1].max * 5,
#   :fallback_policy => :abort
# )


# future = Concurrent::Future.execute(:executor => pool) do


# (ncpu * 2).times do
thread = Thread.new {
  	while true
		if !work_queue.empty?
			client = work_queue.pop(true) rescue nil
			if client
				main_handler(client)
			end
	 	end

	 	if interrupt
	 		break
	 	end
	end
}
# end


begin
	loop do 
	  	work_queue << server.accept  
	end
rescue Interrupt => e
	interrupt = true
	server.close
	puts " - The server shuts down..."
	thread.join
end
