### 
 # Created by anthony on 25.09.16.
 ## 

require 'socket'

require './config'
require './handlers'
require './threadpool'
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

server = TCPServer.new host, port
puts "Listen #{host} on #{port}..."
pool = ThreadPool.new ncpu


# Kernel.trap('INT') do
#   server.close
#   puts " - The server shuts down..."
#   exit
# end


loop do 
  pool.put_client(server.accept)  
  pool.run
end
