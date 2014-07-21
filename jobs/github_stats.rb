require 'octokit'
require 'action_view'
include ActionView::Helpers::DateHelper

Octokit.configure do |c|
  c.auto_paginate = true
  c.login = ENV["GITHUB_LOGIN"]
  c.password = ENV["GITHUB_PASSWORD"]
end

github_repos  = ENV["GITHUB_REPOS"].to_s.split(',')

SCHEDULER.every '2m', :first_in => 0 do |job|
  github_repos.each do |name|
    
    r = Octokit::Client.new.repository(name)
    commits = Octokit.commits(name).count

    send_event(name, {
      repo: name,
      commits: commits,
      activity: time_ago_in_words(r.updated_at).capitalize
    })
  end
end
