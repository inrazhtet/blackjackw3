require 'rubygems'
require 'sinatra'

set :sessions, true

get '/helloworld'  do
	"Hello World!!"
end

get '/ztemplate' do
  erb :ztemplate
end

get '/nested_template' do
  erb :"user/profile"
end

get '/nothere' do
  redirect '/helloworld'
end

get '/form' do
  erb :subform
end

post '/zaction' do
  puts params['username']
end