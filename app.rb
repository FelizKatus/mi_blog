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
  @db = init_db
end

configure do
  @db = init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS [Posts] (
    [title] TEXT,
    [content] TEXT,
    [created_date] DATE
  )'
end

get '/' do
  @all_posts = @db.execute 'SELECT * FROM Posts ORDER BY rowid DESC'

  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  @title   = params[:title]
  @content = params[:content]

  hh = {:title   => 'Type a title',
        :content => 'Type a post text'}

  hh.each do |key, value|
    if params[key] == ''
      @error = hh[key]
      return erb :new if @error.length > 1
    end
  end

  @db.execute 'INSERT INTO Posts (title, content, created_date) VALUES (?, ?, datetime())', [@title, @content]

  @message = "Congratulations! The new post created."

  erb :new
end