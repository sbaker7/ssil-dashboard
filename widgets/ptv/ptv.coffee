class Dashing.Ptv extends Dashing.Widget
  onData: (data) ->
    console.log data
    for departure in data.departures
      departure.display =
        title: "#{departure.destination_name} #{departure.express}"
        mins_to_depart: moment(departure.time.timetable).diff(moment(), 'minutes')