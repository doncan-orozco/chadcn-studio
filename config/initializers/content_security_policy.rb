# Be sure to restart your server when you modify this file.

# Content security policy of every HTML response, enforced in all environments. Scripts are same-origin importmap
# modules plus the nonced importmap and module tags (the nonce is random per request; Turbo Drive matches head scripts
# without it, so never put an inline <script> in <body>). Styles need `unsafe-inline`: chadcn renders `style`
# attributes AND `<style>` elements (ScrollArea, Chart::Style, the scroll-lock and input-otp controllers), so neither
# a nonce nor `style-src-attr` works. img-src and font-src stay same-origin (plus data:) so injected CSS cannot
# exfiltrate. A blocked resource only logs a securitypolicyviolation; the system suite catches behaviour regressions.
# Turbo Streams over Action Cable use the same origin. See the Securing Rails Applications Guide:
# https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src  :self
    policy.style_src   :self, :unsafe_inline
    policy.img_src     :self, :data
    policy.font_src    :self, :data
    policy.connect_src :self
    policy.object_src  :none
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :none
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
