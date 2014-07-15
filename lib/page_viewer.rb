require 'sinatra/base'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'
require 'docverter'
require 'page_viewer/page'

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

    before '/:page' do
      @page = Page.new(settings.page_root, params[:page])
    end

    get '/' do
      if File.exists?(Page.path('_index'))
        redirect '/_index'
      else
        @title = "Index"
        @files = Dir.glob(Page.path('*')).map { |f| File.basename(f, ".md") }.sort
        erb :index
      end
    end

    get '/:page.md' do
      content_type 'text/plain'
      @page.body
    end

    get '/:page.pdf' do
      @title ||= params[:page].gsub('_', ' ')
      pdf = erb :page, :layout => :pdf
      content_type 'application/pdf'
      Docverter::Conversion.run do |c|
        c.from = 'markdown'
        c.to = 'pdf'
        c.table_of_contents = true
        c.content = @page.body
      end
    end

    get '/:page' do
      @page_name = params[:page]
      @content = RENDERER.render(@page.body)
      @title ||= @page.headers['title'] || params[:page].gsub("_", " ")
      erb :page
    end
  end
end
