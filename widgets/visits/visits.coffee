class Dashing.Visits extends Dashing.Widget
  ready: ->
    # Assume no data initially
    @set 'empty', yes
  onData: (data) ->
    console.log "Visitors!", data
    return
