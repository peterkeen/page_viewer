require 'sinatra'
require 'redcarpet'
require 'pygments'
require 'docverter'

Docverter.base_url = 'http://c.docverter.com'

PAGE_ROOT = ARGV[-1]
unless PAGE_ROOT
  STDERR.puts("usage: app.rb PAGE_ROOT")
  exit 1
end

class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, :lexer => language)
  end

  def postprocess(document)
    document.gsub('&#39;', "'")
  end
end

RENDERER = Redcarpet::Markdown.new(
  HTMLwithPygments,
  :fenced_code_blocks => true
)

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == ENV['USERNAME'] and password == ENV['PASSWORD']
end


get '/' do
  redirect '/_index'
end

get '/:page.md' do
  File.read(File.join(PAGE_ROOT, params[:page] + ".md"))
end


get '/_book.pdf' do
  chapters = File.read(File.join(PAGE_ROOT, 'chapters')).split("\n")
  raw = ""
  chapters.each do |chapter|
    raw << File.read(File.join(PAGE_ROOT, chapter + ".md"))
  end

  @content = RENDERER.render(raw)

  pdf = erb :page, :layout => :pdf
  content_type 'application/pdf'
  Docverter::Conversion.run do |c|
    c.from = 'html'
    c.to = 'pdf'
    c.content = pdf
  end
end

get '/:page.pdf' do
  @content = RENDERER.render(File.read(File.join(PAGE_ROOT, params[:page] + ".md")))
  @title = params[:page].gsub('_', ' ')
  pdf = erb :page, :layout => :pdf
  p pdf
  content_type 'application/pdf'
  Docverter::Conversion.run do |c|
    c.from = 'html'
    c.to = 'pdf'
    c.content = pdf
  end
end

get '/:page' do
  @content = RENDERER.render(File.read(File.join(PAGE_ROOT, params[:page] + ".md")))
  @title = params[:page].gsub("_", " ")
  erb :page
end

