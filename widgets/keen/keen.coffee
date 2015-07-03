class Dashing.Keen extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    console.log("Got some data!")
    console.log(data)
