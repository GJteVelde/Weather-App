### Weather App

I've created this weather app that gets the current weather data via the [OpenWeatherMap API](https://openweathermap.org).
Users have two options to get current weather data for a specific location:

1. Type in a city name in a text field.
2. Scroll on a map and select a location or use their current location.

*When the user wants to use its current location, an alert is shown that asks for permission to get their current location.*

<p align="center"><kbd><img src="https://github.com/GJteVelde/Weather-App/blob/master/City.png" width=300></kbd>   <kbd><img src="https://github.com/GJteVelde/Weather-App/blob/master/Map.png" width=300></kbd></p>

Both options instantiate the same view controller when the 'Show weather' button is pressed. The NetworkService class makes an API call on the background queue and calls the appropriate delegate methods when the call is finished. These delegate methods are used to update the View Controller with the received data.

<p align="center"><kbd><img src="https://github.com/GJteVelde/Weather-App/blob/master/Current%20weather%20data.png" width=300></kbd></p>

Cells in this static table view are automatically hidden when the API didn't send the data. Example: When there was no rain in the last hour, the API doesn't send this. In that case, the app just hides the appropriate cells.
