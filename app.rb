require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'pony'
require 'sinatra/activerecord'

set :database, 'sqlite3:db.sqlite3'

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

before do
  @db = init_db
end

configure do
end

get '/' do
  @all_posts = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'

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

get '/comments/:id' do
  id = params[:id]

  all_posts = @db.execute 'SELECT * FROM Posts WHERE id = ?', [id]
  @post = all_posts[0]

  @comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [id]

  erb :comments
end

post '/comments/:id' do
  id = params[:id]
  name = params[:name]
  content = params[:content]

  hh = {:name   => 'Type your name',
    :content => 'Type a comment'}

  hh.each do |key, value|
    if params[key] == ''
      @error = hh[key]
      return erb :comments if @error.length > 1
    end
  end

  @db.execute 'INSERT INTO Comments (name, content, created_date, post_id) VALUES (?, ?, datetime(), ?)', [name, content, id]

  @message = "Congratulations! The new comment added."

  redirect to('/comments/' + id)
end

get '/contact' do
  erb :contact
end

post '/contact' do
  @name    = params[:name]
  @email   = params[:email]
  @subject = params[:subject]
  @message = params[:message]

  hh = {:name    => 'Su nombre',
        :email   => 'Su email',
        :subject => 'Su subject',
        :message => 'su message'}

  hh.each do |key, value|
    if params[key] == ''
      @error = hh[key]
      return erb :contact if @error != ''
    end
  end

  Pony.mail(
    :from    => params[:name] + "<" + params[:email] + ">",
    :to      => 'username@example.com',
    :subject => params[:name] + " está comunicando",
    :body    => params[:message],
    :via     => :smtp,
    :via_options => { 
      :address              => 'smtp.gmail.com', 
      :port                 => '587', 
      :enable_starttls_auto => true, 
      :user_name            => 'username', 
      :password             => 'password', 
      :authentication       => :plain, 
      :domain               => 'localhost.localdomain'
    })

  erb '¡Gracias! Email sido enviado.'
end