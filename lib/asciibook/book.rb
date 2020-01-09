module Asciibook
  class Book
    attr_reader :data, :options, :doc, :pages

    def initialize(data, options = {})
      @data = data
      @options = options

      @page_level = @options[:page_level] || 1
      @doc = Asciidoctor.load(@data, backend: 'asciibook')
      process_pages
    end

    def title
      doc.attributes['doctitle']
    end

    def toc
      outline(doc)
    end

    def outline(node)
      data = []
      node.sections.each do |section|
        section_data = {
          'title' => section.xreftext,
          'path' => section.page ? section.page.path : "#{find_page_node(section).page.path}##{section.id}"
        }
        if section.level < (doc.attributes['toclevels'] || 2).to_i
          section_data['items'] = outline(section)
        end
        data << section_data
      end
      data
    end

    def find_page_node(node)
      page_node = node

      until page_node.page or page_node.parent.nil?
        page_node = page_node.parent
      end

      page_node
    end

    def to_hash
      {
        'title' => doc.attributes['doctitle'],
        'attributes' => doc.attributes,
        'toc' => toc
      }
    end

    def build
      Builders::HtmlBuilder.new(self).build
    end

    def process_pages
      @pages = []
      process_page(doc)
      @pages
    end

    def process_page(node)
      append_page(node)

      if node.level < @page_level
        node.sections.each do |section|
          process_page(section)
        end
      end
    end

    def append_page(node)
      page = Page.new(node)

      if last_page = @pages.last
        page.prev_page = last_page
        last_page.next_page = page
      end

      node.page = page
      @pages << page
    end
  end
end
