require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'pony'
require 'sinatra/activerecord'

set :database, 'sqlite3:db.sqlite'

class Post < ActiveRecord::Base
end

class Comment < ActiveRecord::Base
end

def init_db
  db = SQLite3::Database.new 'db.sqlite'
  db.results_as_hash = true
  db
end

def seed_db(db)
  db.execute 'INSERT INTO Posts (title, content, created_date) VALUES (?, ?, ?)',
    ['Lorem ipsum dolor sit amet',
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In dictum vestibulum mi eget ullamcorper. Cras porttitor leo at neque ornare, eget tempus lacus hendrerit. Morbi iaculis orci quis neque volutpat convallis. Nam non tempus ante, ut lobortis odio. Nam volutpat sem quis ullamcorper finibus. Curabitur nec mi vel metus facilisis malesuada. Ut tellus nibh, interdum ac blandit sit amet, iaculis a nisi. Mauris efficitur, arcu quis lobortis condimentum, justo enim scelerisque dolor, a aliquet nisl sapien eu magna. Nunc at porttitor dolor. Integer augue dolor, blandit in neque quis, cursus interdum risus.',
      '12-02-2020, 19:15']
  db.execute 'INSERT INTO Posts (title, content, created_date) VALUES (?, ?, ?)',
    ['Mauris vel quam pellentesque',
      'Mauris vel quam pellentesque, viverra mi sed, ultricies ligula. Nulla non urna tincidunt lorem molestie molestie vitae at nisi. Nunc facilisis enim et nunc bibendum viverra. Maecenas tempus suscipit finibus. Curabitur facilisis urna id ullamcorper efficitur. Duis semper quam nec arcu elementum, eu fermentum magna tempus. Nam a diam ac metus varius mollis. Vestibulum aliquam, nunc a feugiat placerat, neque urna rutrum velit, sed egestas quam metus a sem. Suspendisse et sapien sodales, placerat purus ut, euismod ex. Nunc sollicitudin purus non sapien feugiat pellentesque. Etiam facilisis et enim a porta. Sed vel urna fermentum, tincidunt libero sit amet, consequat ex.',
      '12-02-2020, 20:25']
  db.execute 'INSERT INTO Posts (title, content, created_date) VALUES (?, ?, ?)',
    ['Nunc convallis arcu iaculis massa ullamcorper',
      'Nunc convallis arcu iaculis massa ullamcorper, non posuere ante sagittis. Praesent pharetra lectus mauris. Aliquam eu interdum lorem. Vivamus augue arcu, fermentum ut leo non, tempor iaculis tortor. Morbi pretium, orci sit amet porttitor elementum, turpis justo fermentum risus, vitae eleifend est urna vel ligula. Duis aliquet neque vitae dignissim rhoncus. Praesent eu mollis magna, vitae malesuada metus. Praesent eu augue venenatis nulla ullamcorper sagittis.',
      '12-02-2020, 21:35']
  db.execute 'INSERT INTO Posts (title, content, created_date) VALUES (?, ?, ?)',
    ['Fusce fringilla magna nec augue pretium malesuada',
      'Fusce fringilla magna nec augue pretium malesuada. Proin convallis lacus eu rhoncus vestibulum. Nulla placerat neque sed vulputate ullamcorper. Morbi quis mi lorem. Proin iaculis sed tortor eget malesuada. Maecenas mollis leo ut est mattis convallis. Nam nulla velit, pulvinar sed porttitor at, lobortis id libero. Curabitur lorem risus, maximus ut accumsan sed, auctor nec turpis. Integer pellentesque suscipit erat ut maximus. Etiam tempus ut est vel varius. In non nulla elementum, egestas est eget, aliquam nisl.',
      '12-02-2020, 22:45']
  db.execute 'INSERT INTO Posts (title, content, created_date) VALUES (?, ?, ?)',
    ['Mauris elementum nisi eu lectus mattis bibendum',
      'Mauris elementum nisi eu lectus mattis bibendum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quisque enim magna, aliquet a eleifend quis, sagittis at nunc. Praesent vel finibus magna, non maximus lacus. Mauris egestas condimentum velit, vitae vehicula justo hendrerit aliquam. Mauris facilisis nunc feugiat, sollicitudin orci eget, tincidunt diam. Ut ut est tempor, euismod ante tincidunt, mollis nibh. Mauris eleifend sem in augue pharetra, id finibus risus semper. Aliquam erat volutpat. Vivamus arcu mi, blandit at maximus quis, viverra at urna. Duis in faucibus elit. Curabitur maximus pellentesque sem, at eleifend justo molestie bibendum. Quisque suscipit viverra massa non efficitur. Sed aliquet orci et congue volutpat. Nam sed porta nisi.',
      '12-02-2020, 23:55']
end

before do
  @db = init_db
end

configure do
  @db = init_db

  @db.execute 'CREATE TABLE IF NOT EXISTS Posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    content TEXT,
    created_date DATE
  )'

  @db.execute 'CREATE TABLE IF NOT EXISTS Comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id INTEGER,
    name TEXT,
    content TEXT,
    created_date DATE
  )'

  #seed_db(@db)
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