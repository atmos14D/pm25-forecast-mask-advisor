apiKey = 'Insert your API key here';
city = 'Seoul';
url = ['http://api.openweathermap.org/data/2.5/weather?q=', city, '&appid=', apiKey, '&units=metric'];

data = webread(url);
temperature = data.main.temp;
humidity = data.main.humidity;
windSpeed = data.wind.speed;
%Display data
fprintf('\n--- Weather in %s ---\n', city);
fprintf('Temperature: %.1f°C\n',temperature);
fprintf('Humidity: %.0f%%\n',humidity);
fprintf('Wind Speed: %.1f m/s\n',windSpeed);