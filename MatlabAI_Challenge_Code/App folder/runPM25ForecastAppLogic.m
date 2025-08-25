function runPM25ForecastAppLogic(app)

% === Load trained model and normalization parameters ===
load('trainedLSTM_logPM25.mat', 'net', 'mu_X', 'sigma_X', 'mu_Y', 'sigma_Y');

% === Load prediction data (local CSV for model input) ===
T = readtable('air_quality_demo.csv');
dataTime = datetime(T.DataTime, 'InputFormat', 'yyyy-MM-dd HH:mm');
TT = table2timetable(T, 'RowTimes', dataTime);

PM25 = TT.PM25;
PM25(PM25 < 0) = NaN;
X = TT(:, {'Temp', 'Humidity', 'WindSpeed'});
Y = log1p(PM25);

% === Remove NaNs and normalize ===
validIdx = ~isnan(Y);
X = X(validIdx, :);
Y = Y(validIdx);

Xnorm = (table2array(X) - mu_X) ./ sigma_X;
Ynorm = (Y - mu_Y) ./ sigma_Y;

% === Build sequences ===
N = 12;
numSamples = size(Xnorm,1) - N;
Xseq = cell(numSamples,1);
Yseq = zeros(numSamples,1);

for i = 1:numSamples
    Xseq{i} = Xnorm(i:i+N-1, :)';
    Yseq(i) = Ynorm(i+N);
end

% Final NaN check
valid = ~isnan(Yseq);
Xseq = Xseq(valid);
Yseq = Yseq(valid);

% === Predict PM2.5 with trained network ===
Ypred = predict(net, Xseq);

% === Reverse normalization and log-transform ===
Ytrue = expm1(Yseq * sigma_Y + mu_Y);
Ypred_actual = expm1(Ypred * sigma_Y + mu_Y);

% === Advisory decision logic ===
advice = zeros(size(Ypred_actual));
advice(Ypred_actual > 35 & Ypred_actual <= 75) = 1;
advice(Ypred_actual > 75) = 2;

labels = ["No Mask", "Recommended", "Required"];
colors = [0 0.6 0; 1 0.6 0; 1 0 0];

% === Plot predictions and advisory level ===
plot(app.UIAxes, Ytrue, 'k', 'DisplayName', 'Actual PM2.5');
hold(app.UIAxes, 'on');
plot(app.UIAxes, Ypred_actual, 'r--', 'DisplayName', 'Predicted PM2.5');
scatter(app.UIAxes, 1:length(advice), advice, 50, colors(advice+1,:), ...
        'filled', 'DisplayName', 'Advisory Level');
hold(app.UIAxes, 'off');
legend(app.UIAxes, 'show');
title(app.UIAxes, 'PM2.5 Forecast and Mask Advisory');
ylabel(app.UIAxes, 'µg/m³');
xlabel(app.UIAxes, 'Time Step');

% === Lamp color + label based on last prediction ===
lastAdvice = advice(end);
if lastAdvice == 0
    app.Lamp.Color = [0 0.6 0];
    app.LampLabel.Text = '마스크 불필요 (No Mask Needed)';
elseif lastAdvice == 1
    app.Lamp.Color = [1 0.6 0];
    app.LampLabel.Text = '마스크 권장 (Mask Recommended)';
else
    app.Lamp.Color = [1 0 0];
    app.LampLabel.Text = '마스크 필요 (Mask Required)';
    sound(sin(1:3000)*0.5, 8000);  % quick alert beep
end

% === Real-time PM2.5 from Air Korea API ===
try
    apiKey = 'Insert your API here';
    encodedKey = urlencode(apiKey);
    stationName = '종로구'; %district name can be changed to match the one used in KoreaAPI_Data.m file
    url = ['http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?' ...
           'stationName=' urlencode(stationName) ...
           '&dataTerm=DAILY&pageNo=1&numOfRows=1&returnType=xml' ...
           '&serviceKey=' encodedKey '&ver=1.3'];
    options = weboptions('ContentType', 'text', 'Timeout', 15);
    xmlStr = webread(url, options);
    xml = xmlreadstring(xmlStr);
    items = xml.getElementsByTagName('item');
    
    if items.getLength > 0
        item = items.item(0);
        valNode = item.getElementsByTagName('pm25Value').item(0);
        valStr = char(valNode.getFirstChild.getNodeValue());
        pm25RealTime = str2double(valStr);
        
        if pm25RealTime <= 35
            app.Lamp.Color = [0 0.6 0];
            app.LampLabel.Text = '마스크 불필요 (No Mask Needed)';
        elseif pm25RealTime <= 75
            app.Lamp.Color = [1 0.6 0];
            app.LampLabel.Text = '마스크 권장 (Mask Recommended)';
        else
            app.Lamp.Color = [1 0 0];
            app.LampLabel.Text = '마스크 필요 (Mask Required)';
            uialert(app.UIFigure, ...
                '미세먼지 수치가 높습니다. 마스크를 꼭 착용하세요.', ...
                '경고', 'Icon', 'warning');
        end
    end
catch
    uialert(app.UIFigure, 'Failed to fetch real-time PM2.5.', 'API Error');
end

% === ThingSpeak IoT Logging ===
writeKey = 'Insert your thingSpeak key';  % Replace with your real key
thingSpeakWrite(2974125, [Ypred_actual(end), lastAdvice], ...
    'WriteKey', writeKey, ...
    'Fields', [1, 2]);

end
