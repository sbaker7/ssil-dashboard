class Dashing.Keen extends Dashing.Widget
  # How many keen sound effects there are in /assets/keen
  KEEN_SOUNDS = 10
  ready: ->
    # Assume no data initially
    @set 'empty', yes
  onData: (data) ->
    noKeeners = data.keen_count is 0
    @set 'empty', noKeeners
    return if noKeeners
    console.log data.keener.time
    @set 'keenCount', data.keen_count
    @set 'whosKeen' , '@' + data.keener.name
    @set 'lastKeen', moment.unix(data.keener.time).format('h:mm a')
    return unless data.play_sound
    # Play the keen sound
    keenSound = Math.floor(Math.random() * KEEN_SOUNDS)
    new Audio("/sounds/keen/#{keenSound}.WAV").play()