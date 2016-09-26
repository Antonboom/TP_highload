### 
 # Created by anthony on 25.09.16.
 ## 

require 'socket'

require "./handlers.rb"


server = TCPServer.new 8080


loop do
  client = server.accept    

  msg = client.gets.split
  method = msg[0]
  path = msg[1]
  protocol = msg[2]

	case method
	when 'GET'
		get_handler(client, path)
	when 'HEAD'
		head_handler(client, path)
	when 'OPTIONS', 'POST', 'PUT', 'PATCH', 'DELETE', 'TRACE', 'CONNECT'
		not_allowed_handler(client)
	else 
		not_implemented_handler(client)
	end
end
