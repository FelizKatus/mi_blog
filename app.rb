require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'pony'

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
  @db.execute 'CREATE TABLE IF NOT EXISTS [Posts] (
    [id] INTEGER PRIMARY KEY AUTOINCREMENT,
    [title] TEXT,
    [content] TEXT,
    [created_date] DATE
  )'
  # seed_db(@db)
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

# Comments

get '/comments/:id' do
  id = params[:id]

  erb "Displaying information for post with ID #{id}"
end