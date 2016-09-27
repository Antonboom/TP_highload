### 
 # Created by anthony on 25.09.16.
 ## 

require 'socket'
require 'concurrent'

require './config'
require './handlers'
require './optparse'

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
	ncpu = options[:ncpu]
end


work_queue = Queue.new
server = TCPServer.new host, port
puts "Listen #{host} on #{port}..."


pool = Concurrent::ThreadPoolExecutor.new(
  :min_threads => [2, ncpu].max,
  :max_threads => [2, ncpu].max,
  :max_queue   => [2, ncpu].max * 100,
  :fallback_policy => :caller_runs
)


future = Concurrent::Future.execute(:executor => pool) do
  while true
		if !work_queue.empty?
			client = work_queue.pop(true) rescue nil
			if client
				main_handler(client)
			end
	  end
	end
end


loop do 
  work_queue << server.accept  
end


Kernel.trap('INT') do
  server.close
  puts " - The server shuts down..."
  pool.shutdown
  main_thread.exit
  exit
end
