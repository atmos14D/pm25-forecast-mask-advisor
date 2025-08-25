% === CONFIGURATION ===
logFilename = 'air_quality_log.csv';
weatherApiKey = 'Insert your API here';
stationName = '종로구'; %The district name can be changed to match the data in the rest of the scripts
city = 'Seoul';

% === GET WEATHER DATA (OpenWeatherMap) ===
weatherUrl = ['https://api.openweathermap.org/data/2.5/weather?q=' city ...
              '&appid=' weatherApiKey '&units=metric'];
weather = webread(weatherUrl);
temperature = weather.main.temp;
humidity = weather.main.humidity;
windSpeed = weather.wind.speed;

% === GET AIR QUALITY DATA (From variables already in workspace) ===
% Assumes: pm25, pm10, o3, no2, co, so2, khaiIndex, timestamp already exist

% === COMBINE ALL VALUES INTO A ROW ===
row = {datetime('now'), stationName, timestamp, pm25, pm10, o3, no2, co, so2, khaiIndex, temperature, humidity, windSpeed};

% === HEADERS ===
headers = {'LoggedAt', 'Station', 'DataTime', 'PM25', 'PM10', 'O3', 'NO2', 'CO', 'SO2', 'KHAI', 'Temp', 'Humidity', 'WindSpeed'};

% === CHECK FILE AND LOG DATA ===
if ~isfile(logFilename)
    % If the file doesn't exist, create it with headers
    writecell([headers; row], logFilename);
else
    % File exists → check if headers are outdated
    fileData = readcell(logFilename);
    if length(fileData(1,:)) < length(headers)
        % Backup and rebuild file with updated headers
        movefile(logFilename, [logFilename '.bak']);
        writecell([headers; fileData(2:end,:)], logFilename);
    end
    % Append the new row
    writecell(row, logFilename, 'WriteMode', 'append');
end
