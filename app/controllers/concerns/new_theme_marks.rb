# The themes generated and not opened since: the one place that knows the session lists behind the New mark.
# A landing lasts while the user stays on that editor (the Turbo refresh the finished generation broadcasts included);
# any real page view away from it (list, a theme's page, another editor) ends it, so the next opening is the first open.
# Prefetches never count: the browser may fetch pages the user does not open.
module NewThemeMarks
  CAP = 20

  private

  # The editor is about to open on `theme`: the list marks its card New until the editor is opened again after the landing.
  def mark_landed(theme)
    session[:new_theme_ids] = (fresh_theme_ids | [ theme.id ]).last(CAP)
    session[:landing_theme_id] = theme.id
  end

  def fresh_theme_ids = Array(session[:new_theme_ids])

  def leave_landing = (session.delete(:landing_theme_id) unless prefetch_request?)

  # Opening the editor clears the mark, unless this visit belongs to the landing or is only a browser prefetch.
  def acknowledge_landing(theme)
    return if prefetch_request? || landing_on?(theme)

    leave_landing
    session[:new_theme_ids] = fresh_theme_ids - [ theme.id ] if fresh_theme_ids.include?(theme.id)
  end

  def landing_on?(theme) = session[:landing_theme_id] == theme.id

  def prefetch_request? = request.headers["X-Sec-Purpose"] == "prefetch"
end
