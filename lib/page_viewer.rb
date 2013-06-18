require 'sinatra/base'
require 'redcarpet'
require 'pygments'
require 'docverter'

module PageViewer

  class HTMLwithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight(code, :lexer => language)
    end
  
    def postprocess(document)
      document.gsub('&#39;', "'")
    end
  end

  class App < Sinatra::Base

    RENDERER = Redcarpet::Markdown.new(
      HTMLwithPygments.new(:with_toc_data => true),
      :fenced_code_blocks => true,
      :tables => true,
    )

    before do
      Docverter.base_url = ENV['DOCVERTER_URL'] || 'http://c.docverter.com'
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
  end
end
