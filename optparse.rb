### 
 # Created by anthony on 27.09.16.
 ## 

require 'optparse'


def get_options
	options = {}
	
	OptionParser.new do |opts|
	  opts.banner = "Usage: httpd.rb [options]"

	  opts.on('-h', '--host HOST (127.0.0.1)', 'Source host') { |v| options[:host] = v }
	  opts.on('-p', '--port PORT (8080)', 'Source port') { |v| options[:port] = v }
	  opts.on('-r', '--rootdir ROOTDIR (static)', 'DOCUMENT_ROOT') { |v| options[:rdir] = v }
	  opts.on('-c', '--ncpu NCPU (2)', 'Number of CPUs') { |v| options[:ncpu] = v }
	end.parse!

	options
end
