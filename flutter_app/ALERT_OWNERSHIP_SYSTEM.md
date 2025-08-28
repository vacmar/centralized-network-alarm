# Alert Ownership & Dismissal System

## Overview
The Flutter app now includes a comprehensive alert ownership system that ensures only the person who created an alert can dismiss it. This prevents unauthorized users from dismissing critical safety alerts.

## How Alert Ownership Works

### 🆔 **User Identification**
- **Automatic ID Generation**: Each user gets a unique ID when they open the app
  - Format: `user_[timestamp]`
  - Display Name: `User [last3digits]` (e.g., "User 123")
- **Session-Based**: User ID persists for the current app session
- **Visual Display**: Current user name shown in blue badge in app bar

### 🏷️ **Alert Creation & Ownership**
- **Alert ID**: Each dismissible alert gets a unique ID based on creation timestamp
- **Creator Tracking**: Alert stores the user ID of who created it
- **Automatic Ownership**: Test alerts are automatically assigned to current user
- **External Alerts**: Real sensor data can include creator information from backend

### 🔒 **Dismissal Permissions**
- **Owner-Only**: Only the alert creator can dismiss their own alerts
- **Visual Indicators**: 
  - Red "X" button appears only on user's own dismissible alerts
  - "Created by: You" vs "Created by: Other User" labels
  - "(can dismiss)" indicator for own alerts
- **Security**: Attempting to dismiss others' alerts shows error message

## Alert Types & Dismissibility

### ✅ **Dismissible Alerts**
- **Danger Status**: Critical alerts (fire detected, gas leak)
- **Warning Status**: Warning-level alerts (temperature extremes)
- **User-Created**: Alerts created via test buttons
- **Visual**: Show red "X" button if created by current user

### ❌ **Non-Dismissible Alerts**
- **Normal Status**: Regular sensor readings
- **Offline Status**: Sensor connectivity issues
- **System Alerts**: Automatic status updates
- **Visual**: No dismiss button shown

## User Interface Features

### 📱 **App Bar Indicators**
1. **User Badge**: Blue badge showing current user name
2. **Connection Badge**: Green/red badge showing WebSocket status

### 🎛️ **Sensor Cards**
- **Ownership Label**: Shows who created each dismissible alert
- **Dismiss Button**: Red "X" button for user's own alerts only
- **Status Badge**: Color-coded status (Danger/Warning/Normal/Offline)
- **Creator Info**: Small text showing alert creator with permission indicator

### 📝 **Feedback Messages**
- **Success**: Green snackbar when alert dismissed successfully
- **Error**: Red snackbar when trying to dismiss others' alerts
- **Duration**: 2-3 seconds display time

## Testing Functionality

### 🧪 **Test Buttons Available**
1. **Test Flame Alert**: Creates YOUR dismissible flame danger alert
2. **Test Gas Alert**: Creates YOUR dismissible gas danger alert
3. **Test DHT-22 Normal**: Creates non-dismissible normal reading
4. **Other User Alert**: Creates ANOTHER USER'S dismissible alert (you cannot dismiss)
5. **Simulate All Offline**: Forces all sensors offline (non-dismissible)
6. **Clear All**: Removes all alerts and resets display

### 🔍 **Testing Scenarios**
1. **Create Your Alert**: Use "Test Flame Alert" → See red X button → Can dismiss
2. **Other User Alert**: Use "Other User Alert" → No X button for you → Cannot dismiss
3. **Try Unauthorized**: Try to dismiss other user's alert → See error message
4. **Mixed Alerts**: Create multiple alerts from different users → Only yours are dismissible

## Real-World Integration

### 📡 **WebSocket Data Format**
```json
{
  "sensor": "flame",
  "value": true,
  "status": "Danger",
  "timestamp": "2025-08-13T10:30:00Z",
  "alertId": "alert_12345",
  "createdBy": "user_67890",
  "isDismissible": true
}
```

### 🔄 **Alert Lifecycle**
1. **Creation**: Alert created with owner ID and unique alert ID
2. **Display**: Shows with appropriate dismiss button based on ownership
3. **Dismissal**: Only owner can dismiss (sends to backend if needed)
4. **Removal**: Alert removed from display and optionally backend

### 🛡️ **Security Features**
- **Client-Side Validation**: Checks ownership before allowing dismissal
- **User Feedback**: Clear error messages for unauthorized attempts
- **Visual Cues**: Only shows dismiss controls for owned alerts
- **Session Isolation**: Each user session has separate ownership

## Code Architecture

### 📦 **SensorData Model**
```dart
class SensorData {
  final String? alertId;         // Unique alert identifier
  final String? createdBy;       // User ID who created alert
  final bool isDismissible;      // Whether alert can be dismissed
  // ... other fields
}
```

### 🏗️ **Key Methods**
- `_generateUserId()`: Creates unique user session ID
- `_canDismissAlert()`: Checks if current user can dismiss alert
- `_dismissAlert()`: Handles alert dismissal with feedback
- `SensorData.createTestAlert()`: Factory for creating owned test alerts

### 🎨 **UI Components**
- User identification badge in app bar
- Conditional dismiss buttons on sensor cards
- Ownership labels and permission indicators
- Snackbar feedback system

## Benefits

### 👥 **Multi-User Safety**
- Prevents accidental dismissal of others' critical alerts
- Maintains alert accountability and traceability
- Ensures important safety notifications stay visible

### 🔐 **Security & Control**
- Clear ownership boundaries
- Visual feedback for permissions
- Prevents unauthorized alert management

### 📊 **User Experience**
- Intuitive ownership indicators
- Clear visual cues for dismissible alerts
- Helpful error messages for unauthorized actions
- Simple one-click dismissal for own alerts

This system ensures that in a multi-user environment, critical safety alerts remain visible until properly acknowledged by their creator, maintaining the integrity of your centralized alarm system.
