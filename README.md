# Digital Wellbeing App

A Flutter-based Digital Wellbeing application that helps users understand their smartphone usage habits, track screen time, and reduce excessive app usage through daily limits and usage analytics.

## Features

### 📊 Weekly Usage Analysis

* Displays screen time trends for the current week.
* Interactive weekly usage chart.
* Quickly identify high and low usage days.

### ⏱ Today's Screen Time

* Shows total device usage for the current day.
* Updates based on actual app usage statistics collected from Android UsageStats APIs.

### 📱 App Usage Breakdown

* Lists apps used today.
* Displays individual app usage duration.
* Sorted by usage time for easy analysis.

### 🎯 Daily App Limits

Users can set a daily usage limit for specific apps.

Features include:

* Custom daily limits per app.
* Visual progress tracking using Linear Progress Indicators.
* Progress bar changes color when the limit is exceeded.
* Easily identify apps consuming more time than intended.

### ⭐ Track / Untrack Apps

* Choose which apps to monitor.
* Remove apps from tracking when not needed.
* Focus only on apps relevant to your wellbeing goals.

## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/54755d3a-a8e0-42eb-9c2e-dff9e05f68ba" width="30%" alt="Screenshot 1" />
  <img src="https://github.com/user-attachments/assets/aa21a7ef-9d0a-42d5-bd09-8e9f8f87e4b9" width="30%" alt="Screenshot 2" />
</p>

## Tech Stack

* Flutter
* Dart
* BLoC State Management
* Android UsageStats API
* Method Channels (Flutter ↔ Android)
* Hive (Local Storage)

## How It Works

### Usage Tracking

The app collects usage data from Android's UsageStats API and processes it to calculate:

* Daily screen time
* Per-app usage duration
* Weekly usage summaries

### Limit Monitoring

For tracked applications:

1. User sets a daily usage limit.
2. App compares actual usage against the limit.
3. Progress indicator visualizes usage.
4. Indicator turns red when the user exceeds the limit.

## Project Goals

This project aims to help users:

* Build healthier digital habits
* Reduce screen addiction
* Stay aware of daily app usage
* Improve productivity through intentional device usage

## Current Features

* [x] Weekly usage analytics
* [x] Today's total screen time
* [x] Per-app usage tracking
* [x] Daily app limits
* [x] Track / Untrack apps
* [x] Usage progress indicators
* [x] Android UsageStats integration

## Planned Features

* [ ] App usage notifications
* [ ] Weekly wellbeing reports
* [ ] Usage goals and achievements
* [ ] Focus mode
* [ ] App category insights
* [ ] Usage history trends
* [ ] Backup & restore settings

## Permissions Required

### Usage Access Permission

The app requires **Usage Access Permission** to read app usage statistics.

Path:

`Settings → Security & Privacy → Usage Access`

Without this permission, usage data cannot be collected.

## Installation

```bash
git clone https://github.com/yourusername/digital-wellbeing-app.git

cd digital-wellbeing-app

flutter pub get

flutter run
```

## Disclaimer

This application is an independent educational project and is not affiliated with Google's Digital Wellbeing application.



