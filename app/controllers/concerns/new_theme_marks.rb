# The themes generated and not opened since: the one place that knows the session list and the `landed` flash behind it.
module NewThemeMarks
  CAP = 20

  private

  # The editor is about to open on `theme`: the list marks its card New until the editor is opened again.
  def mark_landed(theme)
    session[:new_theme_ids] = (fresh_theme_ids | [ theme.id ]).last(CAP)
    flash[:landed] = true
  end

  def fresh_theme_ids = Array(session[:new_theme_ids])

  # Opening the editor clears the mark, unless this visit is the landing itself (`flash[:landed]`), not a second opening.
  def acknowledge_landing(theme)
    session[:new_theme_ids] = fresh_theme_ids - [ theme.id ] unless flash[:landed]
  end
end
