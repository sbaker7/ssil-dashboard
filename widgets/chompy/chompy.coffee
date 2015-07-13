class Dashing.Chompy extends Dashing.Widget
  # How many chompy sound effects there are in /assets/chompy
  CHOMPY_SOUNDS = 10
  ready: ->
    # Assume no data initially
    @set 'empty', yes
    @set 'chompyImageState', 'static'
  onData: (data) ->
    noChompyers = data.chompy_count is 0
    console.log "CHOMPY!", data
    @set 'empty', noChompyers
    @set 'chompyImageState', if noChompyers then 'static' else 'playing'
    return if noChompyers
    @set 'chompyCount', data.chompy_count
    @set 'whosChompy' , '@' + data.chompyer.name
    @set 'lastChompy', moment.unix(data.chompyer.time).format('h:mm a')
    return unless data.play_sound
    # Play the chompy sound
    chompySound = Math.floor(Math.random() * CHOMPY_SOUNDS)
    new Audio("/sounds/chompy/#{chompySound}.mp3").play()