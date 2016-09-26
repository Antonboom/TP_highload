### 
 # Created by anthony on 27.09.16.
 ## 

require 'mimemagic'
require 'mimemagic/overlay'
require 'uri'
require 'date'

require './config.rb'


def get_headers(status, type=nil, length=nil, last_modified=nil, allow=false)
	headers = [
		"#{PROTOCOL} #{status} #{STATUS_VALUE[status]}",
	 	"Date: #{DateTime.now.strftime(HTTP_DATE_FORMAT)}",
	 	"Server: #{SERVER_NAME}"
	]

	if status == 200
		headers += [
			"Content-Type: #{type}",
			"Content-Length: #{length}",
			"Last-Modified: #{last_modified}"
		]
	end

	if allow
		headers += ["Allow: #{ALLOW_METHODS}"]
	end

	headers += ["Connection: #{CONNECTION_TOKEN}", "", ""]
	headers.join("\r\n")
end


# If the directory is not valid or file is not - 404.
# If you turn on the direct address directory index - 403
# If the directory is correct, then return its index - 200
# If the file is, then bring it back - 200
def get_handler(client, path, body=true)
	path = URI.unescape(File.join(DOCUMENT_ROOT, path))

	if File.file?(path) and path.end_with?(INDEX_PATH)
		client.puts get_headers(STATUS_FORBIDDEN)
		client.close		
	end

	if File.directory?(path)
		path = File.join(path, INDEX_PATH)
	end

	if File.exist?(path)
		mime = MimeMagic.by_path(path).type
		size = File.size?(path)
		modified_time = File.mtime(path).strftime(HTTP_DATE_FORMAT)

		client.puts get_headers(STATUS_OK, mime, size, modified_time)
		if body
			File.open(path, 'rb') do |file|
      	while chunk = file.read(FILE_CHUNK_SIZE)
      		client.write chunk
    		end
  		end
		end
	else
		client.puts get_headers(STATUS_NOT_FOUND)
	end

	client.close
end


def head_handler(client, path)
	get_handler(client, path, body=false)
end


def not_implemented_handler(client)
	client.puts get_headers(STATUS_NOT_IMPLEMENTED, nil, nil, nil, allow=true)
	client.close
end


def not_allowed_handler(client)
	client.puts get_headers(STATUS_METHOD_NOT_ALLOWED, nil, nil, nil, allow=true)
	client.close
end
