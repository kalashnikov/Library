require 'sinatra'
require 'redcarpet'
require 'mongo'
require 'mongo_mapper' 

# 
# Sinatra Configuration
#
set :bind, '106.186.116.54'
set :port, '80'

set :sessions, true
set :logging, true
set :dump_errors, true

enable :sessions

use Rack::Session::Cookie, :key => 'kalaexjkk',
                           :expire_after => 2592000,
                           :secret => '*&(^B235'

#
# Article Setting for ToDo List Object
#
class Article
    include MongoMapper::Document

    key :id,           Integer
    key :title,        String
    key :content,      String
    key :complete,     Boolean
    key :published_at, Time
    timestamps!
end


get '/' do

   # Remove menu file
   %x[rm views/md/menu.md] if File.exist?("views/md/menu.md")

   # Generate Menu file (Markdown format) 
   File.open("views/md/menu.md","w") do |f| 
      f.puts("-----")
      f.puts("## Notes Contents List")

      # Get .md file list and sort 
      flist = Dir.glob("views/md/*.md").sort_by{|w| w.downcase}
      flist.each do |r|
          fname = File.basename(r).split('.')[0]
          next if fname=="menu"
          f.puts ("- [#{fname}](#{fname})")
      end
      f.puts("-----")
   end

   renderer = Redcarpet::Render::HTML.new( :hard_wrap => true, :with_toc_data => true)
   markdown_renderer = Redcarpet::Markdown.new(renderer, :fenced_code_blocks => true, :no_intra_emphasis => true)

   session["kalaexjkk"] = "set"

   file_contents = File.read("views/md/menu.md")

   @title = "Note Contents List"

   @mark = file_contents

   erb :note
end

get '/*' do
  viewname = params[:splat].first

  # Try to load any Markdown file specified in the URL
  if File.exist?("views/md/#{viewname}.md")

    renderer = Redcarpet::Render::HTML.new( :hard_wrap => true, :with_toc_data => true)

    #markdown_renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true, :no_intra_emphasis => true)
    markdown_renderer = Redcarpet::Markdown.new(renderer, :fenced_code_blocks => true, :no_intra_emphasis => true)

    session["kalaexjkk"] = "set"

    file_contents = File.read("views/md/#{viewname}.md")
    
    @title = viewname
    
    #@mark = markdown_renderer.render(file_contents)
    @mark = file_contents

    erb :note

  else
    "Nopers, I can't find it."
  end
end

get '/about' do  
    'A little about me.'  
end 

get '/hello/:name' do 
    'Hello #{params[:name]}.'
end

get '/more/*' do 
    params[:splat]
end

get '/form' do  
    erb :form  
end  

post '/form' do 
    "You said '#{params[:message]}'"
end
