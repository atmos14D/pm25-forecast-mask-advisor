# AI-Powered Air Quality Forecasting and Mask Advisory System for Korea  
**인가지담은 기본 대기지 예측 및 마스크 권장 시스템**

## 📌 Overview  
This project uses real-time air quality data and deep learning to forecast PM2.5 levels and provide smart mask-wearing recommendations to users in Korea. It leverages MATLAB’s AI toolkits, cloud connectivity, and UI design features to deliver a deployable public health solution.

## 🧠 Project Components

### 1. Real-Time Data Collection  
- **Air Korea API** is used to fetch real-time PM2.5 and other pollutant values (pm25Value, khaiIndex, etc.)
- **OpenWeatherMap API** (optional) provides temperature, humidity, and wind speed data for advanced forecasting
- Fetched data is saved in air_quality_log.csv and uploaded to **ThingSpeak** for cloud visualization

### 2. AI Model (LSTM Forecasting)  
- An LSTM model is trained using historical air quality and weather data  
- MATLAB’s **Deep Learning Toolbox** is used for model definition, training, and evaluation
- The model predicts future PM2.5 values, which are later used for mask advisory logic

### 3. Advisory Logic  
- Based on predicted PM2.5 values:
  - 0–35 → No Mask Needed (Green)
  - 36–75 → Mask Recommended (Yellow)
  - 76+ → Mask Required (Red)

### 4. User Interface (App Designer)  
- Built using **MATLAB App Designer**
- Real-time dashboard shows predicted vs. current PM2.5
- Mask advisory shown via color-coded lamp
- Optional: Voice alert + popup warning

### 5. Cloud Monitoring (ThingSpeak)  
- Logs and visualizes PM2.5 and advisory levels
- Korean-labeled dashboard accessible online
- Optional alert triggers via **ThingSpeak React**

---

## 🔧 Tools & Technologies
- MATLAB R2024+ (MATLAB Online or Desktop)
- Deep Learning Toolbox
- App Designer
- Web APIs (Air Korea, OpenWeatherMap)
- ThingSpeak Cloud

---

## 📁 File Structure

| File / Folder              | Description |
|----------------------------|-------------|
| air_quality_log.csv      | Real-time logged data from API |
| air_quality_demo.csv     | Synthetic training data |
| KoreaAPI_DATA.m    | fetches air data from air korea |
| OpenWeatherAPI_DATA.m     | fetches weather data from openweathermap |
| Creation_of_CSV_logFile.m    | Creates logfile with data fetched from air korea |
| xmlreadstring.m | (no need to run) External function used in KoreaAPI_Data file |
| From_LSTM_training_until_plots_with_info.m         | LSTM training script |
| Evaluate_LSTM_performance.m  | To run after training the model to check its performance|
| trainedLSTM_logPM25.m    | Trained model + normalization stats |
| Ypred.mat(variable)                | Saved normalized model predictions |
| App folder       | App Designer UI folder with necessary files |
| README.md                | Project summary and setup |

---

## 🧪 How to Run

1. Make sure your MATLAB has access to:
   - Deep Learning Toolbox
   - App Designer (or MATLAB Online)
2. Run From_LSTM_training_until_plots_with_info.m to train and save prediction data (trainedLSTM_logPM25.m)
3. Open the app (AppInterface.mlapp) and click the "업데이트" button to:
   - Fetch real-time PM2.5 data
   - Predict and visualize mask advisory
4. Optionally:
   - Upload to ThingSpeak using thingSpeakWrite
   - Enable alerts via ThingSpeak React

---

## 📊 Expected Output
- Real-time PM2.5 forecasts plotted
- Lamp color + Korean mask advisory label
- Popup alert for dangerous levels
- Optional audio beep or Korean voice alert
- ThingSpeak cloud dashboard with Korean labels

---

## 🙋 Author  
Danilo Arsenio  G. Joaquim
Electrical & Electronics Engineering + Business Minor  
Korea | Angola

---

## 🔒 License  
This project is for educational and competition purposes only.

