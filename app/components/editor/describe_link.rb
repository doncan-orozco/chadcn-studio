# frozen_string_literal: true

# "Describe a theme": a link to the new page's prompt field. It skips Turbo on purpose: a full load makes the browser focus the
# fragment target, while a Turbo visit would only scroll to it.
class Components::Editor::DescribeLink < Components::Base
  def view_template
    render Chadcn::Button.new(as_child: :a, href: new_theme_path(anchor: Components::Editor::GenerationPanel::PROMPT_ID), variant: "outline", data: { turbo: "false" }) { "Describe a theme" }
  end
end
