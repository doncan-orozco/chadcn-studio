module Themes
  module Operation
    class Publish < Core::Operation
      def call(model:)
        publishable = step ensure_unpublished(model)
        published = step persist_publication(publishable)

        { model: published }
      end

      private

      def ensure_unpublished(model)
        return Success(model) unless model.published?

        fail_with_code!(model, :already_published, message: "This theme is already published.")
      end

      def persist_publication(model)
        return Success(model) if model.update(published_at: Time.current)

        fail_with_model!(model)
      end
    end
  end
end
