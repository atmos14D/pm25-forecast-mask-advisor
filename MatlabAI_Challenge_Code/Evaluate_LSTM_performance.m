% === LOAD TRAINED MODEL AND NORMALIZATION PARAMETERS ===
load('trainedLSTM_logPM25.mat');  % loads: net, mu_X, sigma_X, mu_Y, sigma_Y

% === LOAD DATA ===
data = readtable('air_quality_demo.csv');
dataTime = datetime(data.DataTime, 'InputFormat', 'yyyy-MM-dd HH:mm');
TT = table2timetable(data, 'RowTimes', dataTime);

% === TARGET PREPROCESSING (log1p + filter) ===
PM25 = TT.PM25;
PM25(PM25 < 0) = NaN;
Y = log1p(PM25);  % log(1 + PM2.5)
X = TT(:, {'Temp', 'Humidity', 'WindSpeed'});

% === REMOVE NaNs BEFORE NORMALIZATION ===
validIdx = ~isnan(Y);
X = X(validIdx, :);
Y = Y(validIdx);

% === NORMALIZE ===
Xnorm = (table2array(X) - mu_X) ./ sigma_X;
Ynorm = (Y - mu_Y) ./ sigma_Y;

% === BUILD SEQUENCES ===
N = 12;
numSamples = size(Xnorm, 1) - N;

Xseq = cell(numSamples, 1);
Yseq = zeros(numSamples, 1);

for i = 1:numSamples
    Xseq{i} = Xnorm(i:i+N-1, :)';
    Yseq(i) = Ynorm(i+N);
end

% === CLEAN FINAL SEQUENCES (secondary check) ===
valid = ~isnan(Yseq);
Xseq = Xseq(valid);
Yseq = Yseq(valid);

% === PREDICT ===
Ypred = predict(net, Xseq);

% === UNNORMALIZE & REVERSE LOG ===
Ytrue_log = Yseq * sigma_Y + mu_Y;
Ypred_log = Ypred * sigma_Y + mu_Y;

Ytrue = expm1(Ytrue_log);          % final true PM2.5
Ypred_actual = expm1(Ypred_log);  % final predicted PM2.5

% === METRICS ===
Ytrue(Ytrue < 1) = 1;  % Avoid zero division in MAPE
Ypred_actual(Ypred_actual < 0) = 0;

mape = mean(abs((Ypred_actual - Ytrue) ./ Ytrue)) * 100;
mse = mean((Ypred_actual - Ytrue).^2);
mae = mean(abs(Ypred_actual - Ytrue));

% === PRINT RESULTS ===
fprintf('\nModel Evaluation:\n');
fprintf('MSE  = %.4f µg/m³²\n', mse);
fprintf('MAE  = %.4f µg/m³\n', mae);
fprintf('MAPE = %.2f%%\n', mape);

% === PLOT ===
figure;
plot(Ytrue, 'k', 'DisplayName', 'Actual PM2.5');
hold on;
plot(Ypred_actual, 'r--', 'DisplayName', 'Predicted PM2.5');
xlabel('Time Step');
ylabel('PM2.5 (µg/m³)');
legend('Location', 'best');
title('LSTM Prediction vs Actual PM2.5');
grid on;
