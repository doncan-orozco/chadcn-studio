# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

# The repository tooling (.claude/scripts: the audit receipt and the epic board), not the app. Never boots Rails.
require "rake/testtask"
namespace :test do
  Rake::TestTask.new(:tooling) do |t|
    t.test_files = FileList[".claude/scripts/test/**/*_test.rb"]
    t.warning = false
  end
end
