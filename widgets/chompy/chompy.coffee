class Dashing.Chompy extends Dashing.Widget
  # How many chompy sound effects there are in /assets/chompy
  CHOMPY_SOUNDS = 10
  ready: ->
    # Assume no data initially
    @set 'empty', yes
    @set 'chompyImageState', 'static'
  onData: (data) ->
    noChompiers = data.chompy_count is 0
    console.log "CHOMPY!", data
    @set 'empty', noChompiers
    @set 'chompyImageState', if noChompiers then 'static' else 'playing'
    return if noChompiers
    @set 'chompyCount', data.chompy_count
    @set 'whosChompy' , '@' + data.chompier.name
    @set 'lastChompy', moment.unix(data.chompier.time).format('h:mm a')
    return unless data.play_sound
    # Play the chompy sound
    chompySound = Math.floor(Math.random() * CHOMPY_SOUNDS)
    new Audio("/sounds/chompy/#{chompySound}.mp3").play()
