require "test_helper"
require "open3"

class SecurityHeadersTest < ActionDispatch::IntegrationTest
  PAGES = {
    "the root" => -> { "/" },
    "the editor" => -> { "/themes/#{themes(:zinc).to_param}/edit" },
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

  PAGES.each do |name, path|
    test "every inline script on #{name} carries the nonce of the policy" do
      get instance_exec(&path)

      nonce = directive("script-src")[/'nonce-([^']+)'/, 1]

      assert_select "meta[name=csp-nonce][content='#{nonce}']"
      assert_select "script[type=importmap][nonce='#{nonce}']"
      assert_select "script:not([src])" do |scripts|
        scripts.each { |script| assert_equal nonce, script["nonce"], script.to_html.truncate(80) }
      end
    end
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

  test "the production config refuses an APP_HOST that is not a bare hostname" do
    [ "https://studio.example.com", "studio.example.com:443", "studio.example.com/app" ].each do |value|
      _output, status = run_production_runner("APP_HOST" => value)

      assert_not status.success?, "expected #{value} to be refused"
    end
  end

  private

  def directive(name)
    response.headers["Content-Security-Policy"].split(";").map(&:strip).find { |part| part.start_with?("#{name} ") }.to_s.delete_prefix("#{name} ")
  end

  # Boots a production runner in a subprocess: production.rb reaches for `Rails.application`, so it cannot be
  # evaluated in the test process without reconfiguring the running app.
  def run_production_runner(env)
    script = <<~RUBY
      exclude = Rails.application.config.host_authorization.fetch(:exclude)
      request = ->(path) { Struct.new(:path).new(path) }
      puts "CONFIG=" + JSON.generate(hosts: Rails.application.config.hosts.to_a, up_excluded: exclude.call(request.call("/up")), other_excluded: exclude.call(request.call("/themes")))
    RUBY
    Open3.capture2(
      { "RAILS_ENV" => "production", "SECRET_KEY_BASE_DUMMY" => "1", "APP_HOST" => nil }.merge(env),
      Rails.root.join("bin/rails").to_s, "runner", script, chdir: Rails.root.to_s
    )
  end

  def production_config(env)
    output, status = run_production_runner(env)

    assert_predicate status, :success?, "production runner failed"
    JSON.parse(output.lines.reverse.find { |line| line.start_with?("CONFIG=") }.delete_prefix("CONFIG="), symbolize_names: true)
  end
end
