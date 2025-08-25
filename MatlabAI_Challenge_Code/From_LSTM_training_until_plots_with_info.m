% === LOAD DATA ===
data = readtable('air_quality_demo.csv');
dataTime = datetime(data.DataTime, 'InputFormat', 'yyyy-MM-dd HH:mm');
TT = table2timetable(data, 'RowTimes', dataTime);

PM25 = TT.PM25;
PM25(PM25 < 0) = NaN;
X = TT(:, {'Temp', 'Humidity', 'WindSpeed'});
Y = log1p(PM25);

% REMOVE NaNs BEFORE BUILDING SEQUENCES
validIdx = ~isnan(Y);
X = X(validIdx, :);
Y = Y(validIdx);

% Normalize
[Xnorm, mu_X, sigma_X] = normalize(table2array(X));
[Ynorm, mu_Y, sigma_Y] = normalize(Y);

% Recalculate sample count
N = 12;
numSamples = size(Xnorm, 1) - N;

% === BUILD SEQUENCES ===
Xseq = cell(numSamples, 1);
Yseq = zeros(numSamples, 1);

for i = 1:numSamples
    Xseq{i} = Xnorm(i:i+N-1, :)';
    Yseq(i) = Ynorm(i+N);
end

% SECONDARY SAFETY FILTER (rare case)
valid = ~isnan(Yseq);
Xseq = Xseq(valid);
Yseq = Yseq(valid);

% REMOVE NaNs FROM Yseq
validIdx = ~isnan(Y);       % Only keep valid rows
X = X(validIdx, :);          % same rows from X
Y = Y(validIdx);             % clean Y

%[Xnorm, mu_X, sigma_X] = normalize(table2array(X));
%[Ynorm, mu_Y, sigma_Y] = normalize(Y);
% === LSTM ARCHITECTURE ===
inputSize = size(Xnorm, 2);
numHiddenUnits = 100;

layers = [
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits, 'OutputMode', 'last')
    dropoutLayer(0.2)
    fullyConnectedLayer(1)
    regressionLayer
];

options = trainingOptions('adam', ...
    'MaxEpochs', 300, ...
    'MiniBatchSize', 32, ...
    'Plots', 'training-progress', ...
    'Verbose', 0);

%Before training
disp('--- Yseq preview ---');
disp(Yseq(1:10));

disp('Any NaN in Yseq?');
disp(any(isnan(Yseq)));

disp('Size of Yseq:');
disp(size(Yseq));

disp('Class of Yseq:');
disp(class(Yseq));

disp('Is Xseq a cell array?');
disp(iscell(Xseq));
disp('Size of Xseq:');
disp(size(Xseq));
disp('Class of Xseq{1}:');
disp(class(Xseq{1}));
disp('Size of Xseq{1}:');
disp(size(Xseq{1}));

assert(all(~isnan(Yseq)), '❌ Yseq still contains NaN values after filtering.');
assert(iscell(Xseq) && isnumeric(Yseq), '❌ Training data format is incorrect.');

% === TRAIN MODEL ===
net = trainNetwork(Xseq, Yseq, layers, options);

% === SAVE TRAINED MODEL & STATS ===
save('trainedLSTM_logPM25.mat', 'net', 'mu_Y', 'sigma_Y', 'mu_X', 'sigma_X');

% === LATEST SEQUENCE PREDICTION (optional real-time usage) ===
latestSequence = Xnorm(end-N+1:end, :)';
predictedNorm = predict(net, {latestSequence});
predictedPM25 = expm1(predictedNorm * sigma_Y + mu_Y);  % final µg/m³

fprintf('\nLatest predicted PM2.5: %.2f µg/m³\n', predictedPM25);

% === Predict on all sequences ===
Ypred = predict(net, Xseq);

% === Unnormalize and reverse log ===
Ytrue_log = Yseq * sigma_Y + mu_Y;
Ypred_log = Ypred * sigma_Y + mu_Y;

Ytrue = expm1(Ytrue_log);
Ypred_actual = expm1(Ypred_log);

% === PLOT: Actual vs Predicted ===
figure;
plot(Ytrue, 'k', 'DisplayName', 'Actual PM2.5');
hold on;
plot(Ypred_actual, 'r--', 'DisplayName', 'Predicted PM2.5');
legend('Location', 'best');
xlabel('Time Step');
ylabel('PM2.5 (µg/m³)');
title('LSTM Forecast: PM2.5 Prediction vs Actual');
grid on;

% === MASK-WEARING ADVISORY ===
advice = zeros(size(Ypred_actual));                     % 0 = No Mask
advice(Ypred_actual > 35 & Ypred_actual <= 75) = 1;     % 1 = Recommended
advice(Ypred_actual > 75) = 2;                          % 2 = Required

labels = ["No Mask", "Recommended", "Required"];
colors = [0 0.6 0; 1 0.6 0; 1 0 0];  % Green, Orange, Red

% === PLOT: Overlay Advisory Zone ===
figure;
yyaxis left
plot(Ytrue, 'k', 'DisplayName', 'Actual PM2.5');
hold on;
plot(Ypred_actual, 'r--', 'DisplayName', 'Predicted PM2.5');
ylabel('PM2.5 (µg/m³)');
ylim([0 max([Ytrue; Ypred_actual]) + 10])

yyaxis right
scatter(1:length(advice), advice, 50, colors(advice+1,:), 'filled', ...
    'DisplayName', 'Advisory Level');
ylabel('Advisory');
yticks([0 1 2]);
yticklabels(labels);
ylim([-0.5 2.5])

title('Mask-Wearing Advisory Based on LSTM PM2.5 Prediction');
xlabel('Time Step');
legend('Location', 'northwest');
grid on;
