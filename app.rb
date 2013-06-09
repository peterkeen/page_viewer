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
  HTMLwithPygments.new(:with_toc_data => true),
  :fenced_code_blocks => true,
)
TOC_RENDERER = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML_TOC
)

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == ENV['USERNAME'] and password == ENV['PASSWORD']
end

def page_contents(page)
  File.read(File.join(PAGE_ROOT, page + '.md'))
end

get '/' do
  redirect '/_index'
end

get '/:page.md' do
  content_type 'text/plain'
  page_contents(params[:page])
end

get '/_book' do
  @page_name = '_book'
  chapters = File.read(File.join(PAGE_ROOT, 'chapters')).split("\n")
  raw = ""
  chapters.each do |chapter|
    raw << page_contents(chapter)
  end
  book_content = RENDERER.render(raw)
  toc_content = TOC_RENDERER.render(raw)

  @content = page_contents('cover') + toc_content + book_content

  @title = "Mastering Modern Payments: Using Stripe with Rails"

  erb :page
end

get '/_book.pdf' do
  chapters = File.read(File.join(PAGE_ROOT, 'chapters')).split("\n")
  raw = ""
  chapters.each do |chapter|
    raw << page_contents(chapter)
  end

  book_content = RENDERER.render(raw)
  toc_content = TOC_RENDERER.render(raw)

  @content = page_contents('cover') + toc_content + book_content

  pdf = erb :page, :layout => :pdf
  content_type 'application/pdf'
  Docverter::Conversion.run do |c|
    c.from = 'html'
    c.to = 'pdf'
    c.content = pdf
  end
end

get '/:page.pdf' do
  @content = RENDERER.render(page_contents(params[:page]))
  @title = params[:page].gsub('_', ' ')
  pdf = erb :page, :layout => :pdf
  content_type 'application/pdf'
  Docverter::Conversion.run do |c|
    c.from = 'html'
    c.to = 'pdf'
    c.content = pdf
  end
end

get '/:page' do
  @page_name = params[:page]
  @content = RENDERER.render(page_contents(params[:page]))
  @title = params[:page].gsub("_", " ")
  erb :page
end

