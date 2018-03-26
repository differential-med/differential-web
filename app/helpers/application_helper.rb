module ApplicationHelper
  def self.markdown_renderer
    @markdown_renderer ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML
    )
  end

  def render_markdown(str)
    ApplicationHelper.markdown_renderer.render(str).html_safe
  end
end
