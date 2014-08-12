require 'travis'
require 'travis/pro'

# Updates build status for the given repo_name.
def get_build_status(repo_name, type)
  repo = nil
  build_info = nil

  # Get Travis API token.
  if type == :private
    Travis::Pro.access_token = ENV["TRAVIS_AUTH_TOKEN_PRO"]
    repo = Travis::Pro::Repository.find(repo_name)
  elsif type == :public
    Travis.access_token = ENV["TRAVIS_AUTH_TOKEN_ORG"]
    repo = Travis::Repository.find(repo_name)
  end

  # Get details of last build.
  unless repo.nil?
    build = repo.last_build
    build_info = {
      repo_name: repo_name,
      repo_type: type,
      build_num: build.number,
      branch: build.branch_info,
      commit_id: build.commit.short_sha,
      commit_msg: build.commit.subject,
      status: build.state,
      color: build.color,
      duration_secs: build.duration
    }
  else
    puts "[Travis CI] Repo #{repo_name} not found."
  end

  build_info
end

# Hit Travis periodically to get new data.
SCHEDULER.every('3s', first_in: '1s') {
  private_repos = ENV["TRAVIS_REPOS_PRO"].to_s.split(',')
  public_repos  = ENV["TRAVIS_REPOS_ORG"].to_s.split(',')

  builds = []
  private_repos.each { |repo| builds << get_build_status(repo, :private) }
  public_repos.each { |repo| builds << get_build_status(repo, :public) }

  send_event('travis-list', builds: builds)
}
