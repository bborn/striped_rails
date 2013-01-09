module StripedRails
  class PageDecorator < BaseDecorator
    decorates :page, :class => StripedRails::Page

    def menu(pages)
      if page.title?
        h.content_tag(:li, class: 'dropdown', id: 'about_menu') do
          (h.link_to '#', { class: 'dropdown-toggle', data: { toggle: 'dropdown' } } do
            (page.title +
            h.content_tag(:b, '', class: 'caret')).html_safe
          end).html_safe +
          (h.content_tag(:ul, class: 'dropdown-menu') do
            (pages.inject('') do |links, p|
              links += h.content_tag(:li, h.link_to(p.title, h.page_path(p)))
            end).html_safe
            # Check for admin here.
          end)
        end
      end
    end

    def content
      Haml::Engine.new(page.content).render.html_safe
    end

  end
end