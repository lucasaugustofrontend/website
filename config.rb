require 'redcarpet'
require 'active_support'
require 'active_support/core_ext'
require 'support-for'

Dir['./lib/*'].each { |f| require f }

ignore /[a-z]{2}-[A-Z]{2}$/

# Debugging
set(:logging, ENV['RACK_ENV'] != 'production')

activate :relative_assets
set :relative_links, true

set :markdown_engine, :redcarpet
set :markdown, :layout_engine => :erb,
         :fenced_code_blocks => true,
         :lax_html_blocks => true,
         :renderer => Highlighter::HighlightedHTML.new

activate :directory_indexes
activate :toc
activate :highlighter
activate :alias

def current_guide(mm_instance, current_page)
  path = current_page.path.gsub('.html', '').gsub("guides/", "")
  guide_path = path.split("/")[0]

  current_guide = mm_instance.data.guides.find do |guide|
    guide.url == guide_path
  end

  current_guide
end

def current_chapter(mm_instance, current_page)
  guide = current_guide(mm_instance, current_page)
  return unless guide

  path = current_page.path.gsub('.html', '').gsub("guides/", "")
  chapter_path = path.split('/')[1..-1].join('/')

  current_chapter = guide.pages.find do |chapter|
    chapter.url == chapter_path
  end

  current_chapter
end

###
# Build
###
configure :build do
  activate :minify_css
  activate :minify_javascript, ignore: /.*examples.*js/
  activate :html_proofer
end

###
# Pages
###
page '404.html', directory_index: false

page 'guides*', layout: :guides

# Don't build layouts standalone
ignore '*_layout.erb'

###
# Helpers
###
helpers do
  # Workaround for content_for not working in nested layouts
  def partial_for(key, partial_name=nil)
    @partial_names ||= {}
    if partial_name
      @partial_names[key] = partial_name
    else
      @partial_names[key]
    end
  end

  def rendered_partial_for(key)
    partial_name = partial_for(key)
    partial(partial_name) if partial_name
  end

  def page_classes
    classes = super
    return 'not-found' if classes == '404'
    classes
  end
end
