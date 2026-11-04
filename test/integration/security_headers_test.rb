require "test_helper"
require "open3"

class SecurityHeadersTest < ActionDispatch::IntegrationTest
  PAGES = {
    "the root" => -> { "/" },
    "the editor" => -> { "/themes/#{Theme.first.to_param}/edit" },
    "a preview" => -> { "/previews/dashboard" }
  }.freeze

  PAGES.each do |name, path|
    test "#{name} enforces a policy whose script-src has a nonce and no unsafe-inline" do
      get instance_exec(&path)

      assert_response :success
      assert_nil response.headers["Content-Security-Policy-Report-Only"]
      script_src = directive("script-src")
      assert_match(/'nonce-[^']+'/, script_src)
      assert_no_match(/unsafe-inline/, script_src)
      assert_includes script_src, "'self'"
    end
  end

  test "the importmap script carries the nonce of the policy" do
    get root_path

    nonce = directive("script-src")[/'nonce-([^']+)'/, 1]
    assert_select "script[type=importmap][nonce='#{nonce}']"
    assert_select "meta[name=csp-nonce][content='#{nonce}']"
  end

  test "the policy lets chadcn style attributes through but loads nothing from other origins" do
    get root_path

    assert_includes directive("style-src"), "'unsafe-inline'"
    assert_no_match(/nonce/, directive("style-src"))
    assert_equal "'self'", directive("connect-src")
    assert_equal "'none'", directive("object-src")
    assert_equal "'none'", directive("frame-ancestors")
    assert_no_match(%r{https?:}, response.headers["Content-Security-Policy"])
  end

  test "every request gets a fresh nonce" do
    get root_path
    first = directive("script-src")[/'nonce-([^']+)'/, 1]
    get root_path

    assert_not_equal first, directive("script-src")[/'nonce-([^']+)'/, 1]
  end

  test "the production config authorizes APP_HOST and lets /up through" do
    config = production_config("APP_HOST" => "studio.example.com")

    assert_equal [ "studio.example.com" ], config[:hosts]
    assert config[:up_excluded]
    assert_not config[:other_excluded]
  end

  test "the production config leaves hosts empty without APP_HOST" do
    assert_empty production_config("APP_HOST" => nil)[:hosts]
  end

  private

  def directive(name)
    response.headers["Content-Security-Policy"].split(";").map(&:strip).find { |part| part.start_with?("#{name} ") }.to_s
  end

  # Boots a production runner in a subprocess: production.rb reaches for `Rails.application`, so it cannot be
  # evaluated in the test process without reconfiguring the running app.
  def production_config(env)
    script = <<~RUBY
      exclude = Rails.application.config.host_authorization.fetch(:exclude)
      request = ->(path) { Struct.new(:path).new(path) }
      puts JSON.generate(hosts: Rails.application.config.hosts.to_a, up_excluded: exclude.call(request.call("/up")), other_excluded: exclude.call(request.call("/themes")))
    RUBY
    output, status = Open3.capture2(
      { "RAILS_ENV" => "production", "SECRET_KEY_BASE_DUMMY" => "1", "APP_HOST" => nil }.merge(env),
      Rails.root.join("bin/rails").to_s, "runner", script, chdir: Rails.root.to_s
    )
    assert status.success?, "production runner failed"
    JSON.parse(output.lines.last, symbolize_names: true)
  end
end
