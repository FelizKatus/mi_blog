require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'pony'

get '/' do
  'Hello, world!'
end