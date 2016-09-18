require 'sinatra/base'
require 'rubygems'

# require ''
# require_relative ''


class Server < Sinatra::Base
	configure do
		set :show_exceptions, true
		set :raise_errors, true
  		set :raise_sinatra_param_exceptions, true
	end

  	def initialize
  		super
  	end

  	get '/' do
  		"HELLO HIGHLOAD SERVER"
  	end
end	# class Server		
					