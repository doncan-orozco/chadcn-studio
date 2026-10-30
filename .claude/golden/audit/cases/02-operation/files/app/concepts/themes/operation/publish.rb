module Themes
  module Operation
    class Publish < Core::Operation
      def call(theme_id:)
        theme = Theme.find(theme_id)
        user = Current.user

        Theme.transaction do
          theme.update!(published_at: Time.current, publisher: user)
        end

        flash[:notice] = "Theme published"
        redirect_to theme_path(theme)

        Success(theme)
      end
    end
  end
end
