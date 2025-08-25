# 인공지능 기반 대기질 예측 및 마스크 권장 시스템

## 📌 개요
본 프로젝트는 실시간 대기질 데이터를 수집하고 딥러닝 기반의 LSTM 모델을 통해 PM2.5 농도를 예측하여 사용자에게 마스크 착용 권장 수준을 안내합니다. MATLAB의 AI 툴킷, 클라우드 연결 기능, UI 디자이너를 활용하여 공공 보건에 기여할 수 있는 응용 프로그램을 구현했습니다.

## 🧠 프로젝트 구성

### 1. 실시간 데이터 수집
- **Air Korea API**를 사용하여 PM2.5, KHAI 지수 등의 대기오염 물질 데이터를 실시간으로 수집합니다.
- **OpenWeatherMap API**(선택 사항)는 온도, 습도, 풍속 정보를 제공합니다.
- 수집된 데이터는 `air_quality_log.csv` 파일에 저장되며, **ThingSpeak**를 통해 클라우드에서 시각화됩니다.

### 2. AI 모델 (LSTM 기반 예측)
- 과거 대기질 및 기상 데이터를 기반으로 LSTM 모델을 학습합니다.
- MATLAB의 **Deep Learning Toolbox**를 사용하여 모델을 정의하고 학습 및 평가합니다.
- 학습된 모델은 미래 PM2.5 값을 예측하며, 마스크 권장 기준에 사용됩니다.

### 3. 마스크 권장 로직
- 예측된 PM2.5 값을 기준으로 다음과 같이 분류합니다:
  - 0–35 → 마스크 필요 없음 (초록색)
  - 36–75 → 마스크 권장 (노란색)
  - 76 이상 → 마스크 필수 (빨간색)

### 4. 사용자 인터페이스 (App Designer)
- **MATLAB App Designer**를 사용하여 UI를 구성했습니다.
- 실시간 대시보드에서 예측값과 현재 PM2.5를 시각적으로 비교합니다.
- 색상 램프로 마스크 권장 여부를 표시하고, 음성 알림 및 팝업 경고도 추가할 수 있습니다.

### 5. 클라우드 모니터링 (ThingSpeak)
- PM2.5 및 권장 수준을 실시간으로 기록하고 시각화합니다.
- 한국어로 라벨링된 대시보드를 웹에서 확인할 수 있습니다.
- **ThingSpeak React**를 통해 조건부 알림도 구현 가능합니다.

---

## 🔧 사용 도구 및 기술
- MATLAB R2024+ (MATLAB Online 또는 Desktop)
- Deep Learning Toolbox
- App Designer
- Web API (Air Korea, OpenWeatherMap)
- ThingSpeak Cloud

---

## 📁 파일 구성

| 파일 / 폴더                 | 설명 |
|----------------------------|------|
| air_quality_log.csv      | 실시간 수집된 대기질 데이터 |
| air_quality_demo.csv     | 학습용 예시 데이터 |
| KoreaAPI_DATA.m          | Air Korea API 데이터 수집 코드 |
| OpenWeatherAPI_DATA.m    | OpenWeather API 데이터 수집 코드 |
| Creation_of_CSV_logFile.m| 로그 파일 생성 스크립트 |
| xmlreadstring.m          | XML 파싱을 위한 외부 함수 |
| From_LSTM_training_until_plots_with_info.m | LSTM 모델 학습 및 시각화 |
| Evaluate_LSTM_performance.m | 모델 성능 평가 스크립트 |
| trainedLSTM_logPM25.m    | 학습된 모델 및 정규화 정보 |
| Ypred.mat                | 저장된 예측 결과 |
| App folder               | 앱 디자이너 파일 폴더 |
| README.md                | 영어 프로젝트 설명 파일 |

---

## 🧪 실행 방법
1. MATLAB에서 다음 툴박스 사용 가능 여부 확인:
   - Deep Learning Toolbox
   - App Designer 또는 MATLAB Online
2. `From_LSTM_training_until_plots_with_info.m`을 실행하여 예측값을 저장
3. AppInterface.mlapp 파일을 열고 "업데이트" 버튼 클릭 시:
   - 실시간 PM2.5 데이터를 수집
   - 예측값 및 권장 수준을 시각화
4. (선택사항)
   - `thingSpeakWrite`로 데이터를 ThingSpeak에 업로드
   - ThingSpeak React로 알림 설정

---

## 📊 기대 결과
- PM2.5 예측 및 실측 데이터 시각화
- 색상 램프 및 한국어 마스크 권장 문구 표시
- 위험 수치 시 팝업 및 음성 알림 기능
- ThingSpeak 클라우드 대시보드 표시 (한국어)

---

## 🙋 개발자
다닐로 아르세니오 G. 조아킴  
전기전자공학 전공 / 경영학 부전공  
대한민국 | 앙골라

---

## 🔒 라이선스
본 프로젝트는 교육 및 경진대회 참가용으로만 사용됩니다.

