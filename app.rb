require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'pony'
require 'sinatra/activerecord'

set :database, 'sqlite3:db.sqlite3'

class Post < ActiveRecord::Base
  has_many :comments

  validates :title, presence: true, length: { minimum: 2 }
  validates :content, presence: true, length: { minimum: 2 }
end

class Comment < ActiveRecord::Base
  belongs_to :post

  validates :name, presence: true, length: { minimum: 2 }
  validates :content, presence: true, length: { minimum: 2 }
end

configure do
end

before do
end

get '/' do
  @all_posts = Post.all

  erb :index
end

get '/new' do
  @p = Post.new
  erb :new
end

post '/new' do
  @p = Post.new params[:post]
  if @p.save
    return erb 'Congratulations! The new post are created.'
  end

  @error = @p.errors.full_messages.first
  erb :new
end

get '/comments/:id' do
  @c = Comment.new
  @p = Post.find(params[:id])

  erb :comments
end

post '/comments/:id' do
  @c = Comment.new params[:comment]
  if @c.save
    return erb 'Congratulations! The new comment added.'
  end

  @error = @c.errors.full_messages.first
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