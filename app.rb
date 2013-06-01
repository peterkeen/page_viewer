require 'sinatra'
require 'redcarpet'
require 'pygments'

PAGE_ROOT = ARGV[0]
unless PAGE_ROOT
  STDERR.puts("usage: app.rb PAGE_ROOT")
  exit 1
end

class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, :lexer => language)
  end
end

RENDERER = Redcarpet::Markdown.new(
  HTMLwithPygments,
  :fenced_code_blocks => true
)

get '/' do
  redirect '/index'
end

get '/:page' do
  @content = RENDERER.render(File.read(File.join(PAGE_ROOT, params[:page] + ".md")))
  @title = params[:page].gsub("_", " ")
  erb :page
end
