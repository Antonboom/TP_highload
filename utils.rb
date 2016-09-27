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
