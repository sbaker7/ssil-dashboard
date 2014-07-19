# SSIL TV Dashboard

Awesome project monitoring dashboard on display in the Swinburne Software Innovation Lab. Powered by [dashing](http://dashing.io/).

## Dependencies

* Ruby 2+
* Bundler

## Getting started

### Setting environment variables

In order to keep auth details and repo names out of this public repository, the following environment variables are used:

* `TRAVIS_AUTH_TOKEN_PRO` - Travis auth token for private repos
* `TRAVIS_AUTH_TOKEN_ORG` - Travis auth token for public repos
* `TRAVIS_REPOS_PRO` - Comma-separated list of owner/repo names to display.
* `TRAVIS_REPOS_ORG` - Comma-separated list of owner/repo names to display.
* `TRELLO_BOARDS` - Comma-separated list of Trello board IDs to display.
* `TRELLO_DEVELOPER_KEY` - API key for Trello.
* `TRELLO_MEMBER_TOKEN` - Member token for Trello.
* `GITHUB_REPOS` - Comma-separated list of owner/repo names
* `GITHUB_LOGIN` - Github username
* `GITHUB_PASSWORD` - Github password

*Note: This setup will eventually be moved into one or more configuration files.*

### Running the server
Run `bundle` to resolve gem dependencies, then run `dashing start` to run the server.