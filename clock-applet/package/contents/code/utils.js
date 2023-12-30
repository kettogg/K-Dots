function parse_wheater(queryData) {
    var raw_location_string = plasmoid.configuration.place
    var split_index = raw_location_string.indexOf(',')
    if (split_index !== -1) {
        p.location_header = raw_location_string.slice(0, split_index)
        p.location_subheader = raw_location_string.slice(split_index + 1).trim()
    } else
        p.location_header = raw_location_string

    p.station = queryData['Station'] ? queryData['Station'] : ''

    p.temperature = queryData['Temperature'] ? queryData['Temperature'] : 0
    p.temperature_unit = queryData['Temperature Unit'] ? queryData['Temperature Unit'] : 0

    // forecast up to 6 days
    var days = Math.min(queryData['Total Weather Days'], 4)

    forecast.clear()
    for (var i = 0; i < days; i++) {
        var raw_day_forecast = queryData['Short Forecast Day ' + i]
        if (!raw_day_forecast)
            continue

        raw_day_forecast = raw_day_forecast.split('|')
        var day_forecast = {
            when: raw_day_forecast[0].split(' ')[0].trim(),
            icon: raw_day_forecast[1],
            forecast_str: raw_day_forecast[2],
            temperature_max: raw_day_forecast[3],
            temperature_min: raw_day_forecast[4],
            wind_speed: raw_day_forecast[4]
        }
        // print(raw_day_forecast, day_forecast)
        forecast.append(day_forecast)
    }
}
