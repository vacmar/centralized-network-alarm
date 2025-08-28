# Offline Sensor Detection Functionality

## Overview
The Flutter app now includes robust offline sensor detection that automatically identifies when expected sensors are not sending data and displays them with an "Offline" status.

## How It Works

### 🔍 **Sensor Monitoring**
- **Expected Sensors**: The app expects data from 3 specific sensors:
  - `flame` → Flame Sensor
  - `mq6` → MQ-6 Gas Sensor  
  - `dht22` → DHT-22 (Temp & Humidity)

### ⏰ **Offline Detection Logic**
- **Tracking**: Each sensor's last seen time is tracked when data is received
- **Threshold**: If no data is received for **2 minutes**, sensor is marked as offline
- **Check Interval**: Offline status is checked every **30 seconds**
- **Auto-Update**: Offline sensors are automatically added to the display

### 🎨 **Visual Indicators**

#### Offline Status Display
- **Background**: Grey color scheme
- **Icon**: Sensor icon with small WiFi-off indicator overlay
- **Status Badge**: Grey "Offline" label
- **Text**: "Status: No data received" instead of "Reading:"
- **Timestamp**: Shows "Last Seen:" instead of "Last Updated:"

#### Summary Banner
- **Warning Banner**: Shows count of offline sensors when any are detected
- **Orange Warning Icon**: Indicates attention needed
- **Format**: "X sensor(s) offline"

### 🔄 **Lifecycle Behavior**

#### App Startup
- **Initial State**: App starts with no sensor data
- **2-Second Delay**: After 2 seconds, begins checking for offline sensors
- **Auto-Population**: Expected sensors appear as "Offline" if no data received

#### When Data Arrives
- **Automatic Recovery**: Offline sensors immediately switch to active status when data arrives
- **Last Seen Update**: Timestamp is updated for the receiving sensor
- **Real-time Display**: Status changes from "Offline" to actual sensor status

#### Connection Loss
- **Continued Monitoring**: Even if WebSocket disconnects, offline checking continues
- **Graceful Handling**: Sensors remain in last known state until marked offline

### 🧪 **Testing Features**

#### Test Buttons Available
1. **Test Flame Alert**: Simulates flame sensor danger + updates last seen time
2. **Test Gas Alert**: Simulates MQ-6 gas danger + updates last seen time  
3. **Test DHT-22 Normal**: Simulates temperature/humidity normal reading + updates last seen time
4. **Simulate All Offline**: Clears all last seen times and forces all sensors offline

#### Manual Testing
- **Start App**: Wait 2+ seconds to see all sensors appear as offline
- **Test Individual**: Use test buttons to bring sensors online one by one
- **Test Offline**: Use "Simulate All Offline" to reset all sensors to offline
- **Real Data**: Send actual WebSocket data to see sensors come online automatically

### 📡 **WebSocket Integration**

#### Data Reception
```javascript
// When real sensor data is received via WebSocket
{
  "sensor": "flame",
  "value": true,
  "status": "Danger",
  "timestamp": "2025-08-13T10:30:00Z"
}
```

#### Automatic Processing
1. **Parse Data**: Extract sensor type and values
2. **Update Last Seen**: Record current time for the sensor
3. **Remove Offline Entry**: Remove any existing offline status for that sensor  
4. **Add Live Data**: Insert new sensor reading at top of list
5. **Update UI**: Refresh display with new status

### ⚙️ **Configuration Options**

#### Customizable Settings (in code)
```dart
// Offline threshold - how long before marking offline
const offlineThreshold = Duration(minutes: 2);

// Check interval - how often to check for offline sensors  
Timer.periodic(const Duration(seconds: 30), ...);

// Expected sensors mapping
final Map<String, String> _expectedSensors = {
  'flame': 'Flame Sensor',
  'mq6': 'MQ-6 Gas Sensor', 
  'dht22': 'DHT-22 (Temp & Humidity)',
};
```

### 🎯 **User Experience**

#### Clear Status Communication
- **Connection Status**: WebSocket connection shown in app bar (Connected/Disconnected)
- **Sensor Status**: Each sensor clearly marked as Normal/Warning/Danger/Offline
- **Visual Hierarchy**: Offline sensors use muted colors to distinguish from active sensors
- **Helpful Text**: Explains expected behavior when waiting for data

#### Responsive Design
- **Real-time Updates**: No need to refresh, changes appear automatically
- **Smooth Transitions**: Sensors smoothly transition between offline and online states
- **Memory Management**: Only keeps last 50 sensor readings to prevent memory issues

### 🔧 **Error Handling**

#### Robust Design
- **Timer Cleanup**: All timers properly disposed when screen is closed
- **Memory Safety**: Checks `mounted` before setState calls
- **Null Safety**: Handles missing timestamps gracefully
- **Connection Recovery**: Continues working even during connection issues

### 📱 **Production Behavior**

#### Railway Integration
- **Expected Data Flow**: Railway WebSocket → Flutter App → Real-time Display
- **Offline Detection**: If Railway stops sending data → Sensors automatically marked offline
- **Recovery**: When Railway resumes → Sensors automatically come back online
- **No Manual Intervention**: Everything happens automatically

This offline detection system ensures users always know the status of their sensors, whether they're actively sending data, in a danger state, or completely offline due to connection or hardware issues.
