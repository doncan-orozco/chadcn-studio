class Views::Themes::Index < Views::Base
  def view_template
    themes = Theme.where(status: :published).order(:created_at)

    h1 { "Latest themes" }

    themes.each do |theme|
      div(class: theme.archived? ? "text-red-500" : "text-green-600") do
        a(href: "/themes/#{theme.slug}") { "Open" }
      end
    end

    p(style: "color: #0f172a") { "Viewed by #{Current.user.name}" }
  end
end
