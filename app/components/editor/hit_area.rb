# frozen_string_literal: true

# Class strings that widen a gem control's pointer target to at least 24x24 CSS px (WCAG 2.2 SC 2.5.8) with an invisible
# `::after` box, so the control keeps the size shadcn gives it. Passed through the gem's `close_class:` / `thumb_class:`
# options (merged by tailwind-merge) or, for the switch, through `class:` on its button (its thumb does not take pointer events).
module Components::Editor::HitArea
  # The dialog's 16 px X button becomes 28 px (its parent is already `absolute`).
  CLOSE = "after:absolute after:-inset-1.5 after:content-['']"
  # The 16 px slider thumb becomes 28 px; `relative` anchors the box to the thumb, not to the gem's positioning wrapper.
  THUMB = "relative after:absolute after:-inset-1.5 after:content-['']"
  # The 32 x 18.4 px switch becomes 32 x 26.4 px.
  SWITCH = "relative after:absolute after:inset-x-0 after:-inset-y-1 after:content-['']"
end
