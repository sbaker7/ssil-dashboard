class Dashing.Keen extends Dashing.Widget
  # How many keen sound effects there are in /assets/keen
  KEEN_SOUNDS = 40

  # How often to clear the keens, in mins
  CLEAR_KEEN = 30
  keens = {}

  timeout = null

  setupKeens: ->
    # Reset the clearKeens interval
    clearInterval timeout
    timeout = setInterval @clearKeens, CLEAR_KEEN * 60000

  clearKeens: =>
    keens = {}
    @set 'empty', true
    @set 'keenCount', 0
    @set 'whosKeen',  ''

  ready: ->
    # Clear the keens object every CLEAR_KEEN mins
    @setupKeens()

  onData: (data) ->
    # Register who's keen
    whosKeen = data.user_name
    # Can't rekeen
    # return if keens[whosKeen]?
    keens[whosKeen] = moment()
    @set 'empty', false
    @set 'keenCount', Object.keys(keens).length
    @set 'whosKeen' , "@" + whosKeen
    # Reset the clearKeens interval
    @setupKeens()
    # Play the keen sound
    keenSound = Math.floor(Math.random() * KEEN_SOUNDS)
    new Audio("/sounds/keen/#{keenSound}.WAV").play()