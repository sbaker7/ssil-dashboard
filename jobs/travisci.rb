require 'travis'
require 'travis/pro'

# Updates build status for the given repository.
def update_build_status(repository, type)
  builds = []
  repo = nil

  # Get Travis API token.
  if type == :private
    Travis::Pro.access_token = ENV["TRAVIS_AUTH_TOKEN_PRO"]
    repo = Travis::Pro::Repository.find(repository)
  elsif type == :public
    Travis.access_token = ENV["TRAVIS_AUTH_TOKEN_ORG"]
    repo = Travis::Repository.find(repository)
  end

  # Get details of previous build.
  unless repo.nil?
    build = repo.last_build
    build_info = {
      label: "Build #{build.number}",
      value: "[#{build.branch_info}], #{build.state} in #{build.duration}s",
      state: build.state
    }
    builds << build_info
  else
    puts "[Travis CI] Repo #{repository} not found."
  end

  builds
end

# Hit Travis periodically to get new data.
SCHEDULER.every('2m', first_in: '1s') {
  public_repos  = ENV["TRAVIS_REPOS_ORG"].to_s.split(',')
  private_repos = ENV["TRAVIS_REPOS_PRO"].to_s.split(',')

  public_repos.each  { |repo| send_event("travis-#{repo}", { items: update_build_status(repo, :public)  }) }
  private_repos.each { |repo| send_event("travis-#{repo}", { items: update_build_status(repo, :private) }) unless repo.empty? }
}
