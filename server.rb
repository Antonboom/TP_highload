### 
 # Created by anthony on 18.09.16.
 ## 

require "rack"

require "mimemagic"
require "mimemagic/overlay"

require "uri"

STATUS_NOT_IMPLEMENTED = 501
STATUS_NOT_ALLOWED = 405
ALLOW_METHODS = ['GET', 'HEAD'].join(', ')
DOCUMENT_ROOT = 'static'
STATUS_OK = 200
SERVER_NAME = 'WEBrick/1.3.1 (Ruby/2.3.0/2015-12-25)'
HTTP_DATE_FORMAT = '%a, %d %b %Y %H:%M:%S GMT'
STATUS_SERVER_ERROR = 500
INDEX_PATH = 'index.html'
STATUS_NOT_FOUND = 404
STATUS_FORBIDDEN = 403


def not_implemented_handler
	[STATUS_NOT_IMPLEMENTED, { 'Allow' => ALLOW_METHODS }, []]
end


def not_allowed_handler
	[STATUS_NOT_ALLOWED, { 'Allow' => ALLOW_METHODS }, []]
end


class FileStreamer
	def initialize(path)
    	@file = File.open(path)
  	end

  	def each(&block)
    	@file.each(&block)
  	ensure
   		@file.close
  	end
end


## TODO: private fields
class Responce
	def initialize(status=STATUS_SERVER_ERROR, headers={}, body=[])
		@status = status
		@headers = headers
		@body = body
	end

	def set_status(status)
		if status.is_a?(Numeric)
			@status = status  
		else 
			@status = status.to_i
		end
	end

	def set_header(key, value)
		if value.is_a?(String)
			@headers[key] = value 
		else 
			@headers[key] = value.to_s
		end
	end

	def set_body(body)
		@body = body
	end

	def send
		[@status, @headers, @body]
	end
end


# If the directory is not valid or file is not - 404.
# If you turn on the direct address directory index - 403
# If the directory is correct, then return its index - 200
# If the file is, then bring it back - 200
def get_handler(env, body=true)
	responce = Responce.new 
	path = URI.unescape(File.join(DOCUMENT_ROOT, env['PATH_INFO']))

	if File.file?(path) and path.end_with?(INDEX_PATH)
		responce.set_status(STATUS_FORBIDDEN)
		return responce.send		
	end

	if File.directory?(path)
		path = File.join(path, INDEX_PATH)
	end

	if File.exist?(path)
		mime = MimeMagic.by_path(path).type
		size = File.size?(path)

		responce.set_status(STATUS_OK)
		responce.set_header('Content-Type', mime)
		responce.set_header('Content-Length', size)
		responce.set_header('Server', SERVER_NAME)
		responce.set_header('Date', DateTime.now.strftime(HTTP_DATE_FORMAT))
		responce.set_header('Last-Modified', File.mtime(path).strftime(HTTP_DATE_FORMAT))
		if body
			responce.set_body(FileStreamer.new(path))
		end
	else
		responce.set_status(STATUS_NOT_FOUND)
	end

	responce.send
end


def head_handler(env)
	get_handler(env, body=false)
end


def httpd(env)
	method = env['REQUEST_METHOD']

	case method
	when 'GET'
		return get_handler(env)
	when 'HEAD'
		return head_handler(env)
	when 'OPTIONS', 'POST', 'PUT', 'PATCH', 'DELETE', 'TRACE', 'CONNECT'
		return not_allowed_handler()
	else 
		return not_implemented_handler()
	end
		
	[200, {}, [env['REQUEST_METHOD']]]
end


Rack::Handler::WEBrick.run method(:httpd) 
