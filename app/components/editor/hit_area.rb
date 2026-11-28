# frozen_string_literal: true

# Class strings that give a gem control a box of at least 24x24 CSS px on the element itself (WCAG 2.2 SC 2.5.8), which is
# what a pointer, a touch and the audit's probe measure; an `::after` overlay is not part of that box. The control keeps its
# look: the visible shape is painted inside the larger box (a clipped background or a gradient) and the space around it is
# transparent. Passed through the gem's `close_class:` / `thumb_class:` options (merged by tailwind-merge) or, for the switch,
# through `class:` on its button.
module Components::Editor::HitArea
  # The dialog's 16 px X button becomes 24 px; the corner offset moves 4 px in so the X stays where it was.
  CLOSE = "top-3 right-3 flex size-6 items-center justify-center"
  # The 16 px slider thumb becomes 24 px. Its disc (white, 1 px primary edge) is drawn by a gradient in the middle of the box;
  # hover and focus rings are inset so they fill the 4 px band around the disc exactly where the old 4 px ring sat.
  THUMB = "size-6 border-0 bg-transparent bg-[radial-gradient(circle,var(--color-white)_0_7px,var(--color-primary)_7px_8px,transparent_8px)] " \
          "shadow-none drop-shadow-xs hover:ring-inset focus-visible:ring-inset"
  # The 24 px thumb box makes the gem's slider stop a thumb's centre 12 px from each end of its root instead of 8; the root
  # reaches 4 px further on each side and the track keeps its old extent, so the disc meets the track ends where the 16 px
  # thumb did. Goes on the slider's `class:` beside THUMB.
  THUMB_TRACK = "-mx-1 [&>[data-slot=slider-track]]:mx-1"
  # The 32 x 18.4 px switch becomes 32 x 24: the track is painted in the padding box, inside 2.8 px of transparent border
  # above and below; the 1 px side border becomes padding so the thumb keeps its travel. With that border no longer the focus
  # cue (`focus-visible:border-ring`), the focus ring is full strength instead of half.
  SWITCH = "data-[size=default]:h-6 border-x-0 border-y-[0.175rem] px-px bg-clip-padding focus-visible:border-transparent focus-visible:ring-ring shadow-none drop-shadow-xs"
end
