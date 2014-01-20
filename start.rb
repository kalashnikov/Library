require 'sinatra'
require 'rack/protection'
use Rack::Protection

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

    session["kalaexjkk"] = "set"

    file_contents = File.read("views/md/#{viewname}.md")
    
    @title = viewname
    @mark = file_contents

    erb :note

  else
    "Nopers, I can't find it."
  end
end

