# Centralized Network Alarm System - Flutter App

## Overview
This Flutter application connects to a Railway-hosted WebSocket service to display real-time sensor data from three specific sensors:
1. **Flame Sensor** - Detects fire/flame presence
2. **MQ-6 Gas Sensor** - Detects gas levels (LPG, butane, propane)
3. **DHT-22** - Temperature and humidity sensor

## WebSocket Connection
The app connects to: `wss://obsentracore.up.railway.app`

## Features

### 🔥 Real-time Sensor Monitoring
- Live data display from Railway WebSocket
- Automatic reconnection on connection loss
- Visual status indicators (Normal/Warning/Danger)

### 🚨 Alert System
- Visual alerts for dangerous conditions
- Audio alerts (when enabled)
- Color-coded status display

### 📊 Data Display
- Real-time sensor readings
- Timestamp for each reading
- Sensor-specific icons and formatting
- Filter by sensor type

### 🧪 Testing Features
- Simulate flame detection alert
- Simulate gas detection alert
- Test alarm functionality

## Sensor Data Formats

### Expected WebSocket Data Format
```json
{
  "sensor": "flame" | "mq6" | "dht22",
  "value": "sensor reading",
  "status": "Normal" | "Warning" | "Danger",
  "timestamp": "ISO 8601 timestamp"
}
```

### Specific Sensor Examples

#### Flame Sensor
```json
{
  "sensor": "flame",
  "value": true,  // boolean or "Fire Detected"
  "status": "Danger",
  "timestamp": "2025-08-13T10:30:00Z"
}
```

#### MQ-6 Gas Sensor
```json
{
  "sensor": "mq6",
  "value": 450,  // numeric value (>300 triggers danger)
  "status": "Danger",
  "timestamp": "2025-08-13T10:30:00Z"
}
```

#### DHT-22 Temperature & Humidity
```json
{
  "sensor": "dht22",
  "value": {
    "temperature": 25.5,
    "humidity": 60.0
  },
  "status": "Normal",
  "timestamp": "2025-08-13T10:30:00Z"
}
```

## Safety Thresholds

### Automatic Danger Detection
- **Flame Sensor**: Any detection (value > 0 or true) = Danger
- **MQ-6 Gas**: Reading > 300 ppm = Danger
- **DHT-22**: Temperature > 40°C or < 0°C = Warning

## Installation & Setup

### Prerequisites
- Flutter SDK 3.29.2 or higher
- Chrome browser for web testing
- Internet connection for Railway WebSocket

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
# Web version (recommended for testing)
flutter run -d chrome --web-port 8080

# Windows desktop
flutter run -d windows

# Android (if Android SDK is configured)
flutter run -d android
```

## Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/
│   └── sensor_data.dart     # Sensor data model with safety logic
├── screens/
│   ├── welcome_screen.dart  # Landing page
│   └── dashboard_screen.dart # Main sensor dashboard
├── services/
│   └── websocket_service.dart # Railway WebSocket connection
├── utils/
│   └── alert_sound_player.dart # Audio alert functionality
└── widgets/
    ├── custom_button.dart
    └── custom_text_field.dart
```

## WebSocket Service Features
- Automatic reconnection on connection loss
- Flexible data parsing for different sensor formats
- Connection status monitoring
- Error handling and logging

## Dashboard Features
- **Live Connection Status**: Green/Red indicator in app bar
- **Sensor Filtering**: Dropdown to filter by specific sensor types
- **Real-time Updates**: Automatic data refresh from WebSocket
- **Alert Display**: Prominent danger alerts at top of screen
- **Test Buttons**: Simulate sensor alerts for testing
- **Responsive Design**: Works on web, mobile, and desktop

## Testing
1. **WebSocket Connection**: Check connection status indicator
2. **Flame Alert**: Use "Test Flame Alert" button
3. **Gas Alert**: Use "Test Gas Alert" button
4. **Real Data**: Send properly formatted JSON to Railway WebSocket

## Troubleshooting

### Connection Issues
- Verify Railway WebSocket URL is accessible
- Check internet connection
- Look for error messages in console

### No Data Appearing
- Ensure Railway backend is sending data in expected format
- Check WebSocket message format matches expected JSON structure
- Verify sensor names match expected values

### Performance
- App keeps only last 50 sensor readings to prevent memory issues
- Connection automatically reconnects every 5 seconds if lost

## Railway Integration
The app is designed to work specifically with the Railway deployment at `obsentracore.up.railway.app`. The WebSocket service should send JSON data for the three sensors with appropriate status indicators based on safety thresholds.
