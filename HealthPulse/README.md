# HealthPulse (iPhone)

A SwiftUI iPhone app that reads Apple Health (HealthKit) and shows the last 7 days of:

- Steps (daily total)
- Sleep (hours per night)
- Resting heart rate (daily average)

## Run it

You need a Mac with Xcode 15 or newer, and a real iPhone. HealthKit data is limited in the Simulator.

```sh
brew install xcodegen
cd HealthPulse
xcodegen generate
open HealthPulse.xcodeproj
```

In Xcode, choose your Team under **Signing & Capabilities**, change the bundle ID if needed, pick your iPhone, and press Run. Tap **Connect Apple Health** and allow access.

## Google Health / Fit data

iOS has no Google Fit API. To see Google data here, turn on Apple Health syncing in the Google Fit or Fitbit app on your iPhone. The data then reaches this app through HealthKit.
