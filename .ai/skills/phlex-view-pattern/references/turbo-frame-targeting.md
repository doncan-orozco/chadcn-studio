# Safe Turbo Frame Targeting

## RULE 5 — Safe Turbo Frame Targeting

- Frame IDs must be **explicit and stable**; never generate IDs from random or
  session-ephemeral data.
- Use a **static container ID** for list-level swaps (e.g. `"themes_list"`).
- Record-scoped IDs are acceptable when they encode a stable identifier
  (e.g. `"theme_#{theme.uuid}_publish_modal"`).
- Declare **empty placeholder frame tags** at the top of `view_template` so Turbo can
  find them before the rest of the page is parsed.
- Always write `_top` **explicitly** when a link or form submission must break out of a
  frame to navigate or redirect the full page.

```ruby
def view_template
  # Declare modal placeholder first so Turbo can resolve it immediately
  turbo_frame_tag("theme_publish_modal") { }

  turbo_frame_tag "themes_list" do
    # ... list content
  end
end

# Full-page navigation from inside a frame
render Components::Ui::Button.new(
  as: :a,
  href: new_theme_path,
  data: { turbo_method: :post, turbo_frame: "_top" }
) { t("themes.index.new_theme") }
```

For detailed frame decomposition strategies, also load
**[turbo-frames.md](turbo-frames.md)**.

---
