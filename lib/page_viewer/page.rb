module PageViewer
  class Page

    attr_reader :name, :headers, :body

    def self.path(name)
      File.join(PageViewer::App.settings.page_root, name + '.md')
    end
    
    def initialize(name)
      @name = name
      parse_page
    end

    def parse_page
      if contents =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m
        @headers = YAML.load($1)
        @body = $3
      else
        @headers = {}
        @body = contents
      end
    end

    def contents
      @contents ||= File.open(self.class.path(name), 'r:utf-8') do |file|
        file.read
      end
    end
  end
end
