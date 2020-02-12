require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'pony'

def init_db
  db = SQLite3::Database.new 'db.sqlite'
  db.results_as_hash = true
  db
end

before do
  init_db
end

get '/' do
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  title   = params[:title]
  content = params[:content]

  erb "#{title} <br> #{content}"
end