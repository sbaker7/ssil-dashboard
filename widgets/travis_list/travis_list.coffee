class Dashing.TravisList extends Dashing.Widget
  onData: (data) ->
    for build in data.builds
      build.message = "[<span class=\"travis-status-icon\"></span>#{build.branch} #{build.commit_id}] #{build.status} in #{build.duration_secs}s"

  _checkStatus: (status) ->
    $(@node).removeClass('errored failed passed started')
    $(@node).addClass(status)