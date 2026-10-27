# frozen_string_literal: true

# Static sample data of the auth preview page (sign-in and sign-up cards).
class Previews::Presenter::Auth
  def title = "Authentication"
  def product = "Acme"
  def sign_in_title = "Sign in to #{product}"
  def sign_in_error = "Incorrect email or password."
end
