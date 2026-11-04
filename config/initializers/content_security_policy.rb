# Be sure to restart your server when you modify this file.

# Content security policy of every HTML response, enforced in all environments so the system suite fails on a blocked
# resource. Scripts are same-origin importmap modules plus the nonced importmap and Turbo tags. Styles need
# `unsafe-inline` because chadcn components render `style` attributes; a nonce on style-src would make browsers ignore it.
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
