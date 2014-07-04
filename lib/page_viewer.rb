require 'sinatra/base'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'
require 'docverter'

module PageViewer

  class HTMLwithHighlights < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet

    def postprocess(document)
      document.gsub('&#39;', "'")
    end
  end

  class App < Sinatra::Base

    RENDERER = Redcarpet::Markdown.new(
      HTMLwithHighlights.new(:with_toc_data => true),
      :fenced_code_blocks => true,
      :tables => true,
    )

    before do
      Docverter.base_url = 'http://localhost:5000'
    end

    def page_contents(page)
      File.read(page_path(page))
    end

    def page_path(page)
      File.join(settings.page_root, page + '.md')
    end

    get '/' do
      if File.exists?(page_path('_index'))
        redirect '/_index'
      else
        @title = "Index"
        @files = Dir.glob(page_path('*')).map { |f| File.basename(f, ".md") }.sort
        erb :index
      end
    end

    get '/:page.md' do
      content_type 'text/plain'
      page_contents(params[:page])
    end

    get '/:page.pdf' do
      @content = RENDERER.render(page_contents(params[:page]))
      @title ||= params[:page].gsub('_', ' ')
      pdf = erb :page, :layout => :pdf
      content_type 'application/pdf'
      Docverter::Conversion.run do |c|
        c.from = 'markdown'
        c.to = 'pdf'
        c.table_of_contents = true
        c.content = page_contents(params[:page])
      end
    end

    get '/:page' do
      @page_name = params[:page]
      @content = RENDERER.render(page_contents(params[:page]))
      @title ||= params[:page].gsub("_", " ")
      erb :page
    end
  end
end
