class Dashing.Ptv extends Dashing.Widget
  onData: (data) ->
    for departure in data.departures
      departure.display =
        title: "#{departure.destination_name} #{departure.express}"
        departsin: Math.ceil(moment(departure.time.timetable).diff(moment(), 'minutes', true))
        time: moment(departure.time.timetable).format('LT')
    @set 'upTrains', (departure.display for departure in data.departures when departure.to_city)[0..3]
    @set 'downTrains', (departure.display for departure in data.departures when not departure.to_city)[0..3]