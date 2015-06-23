class Dashing.Ptv extends Dashing.Widget
  onData: (data) ->
    console.log data
    for departure in data.departures
      departure.display =
        title: "#{departure.destination_name} #{departure.express}"
        departsin: Math.ceil(moment(departure.time.timetable).diff(moment(), 'minutes', true))
        time: moment(departure.time.timetable).format('LT')