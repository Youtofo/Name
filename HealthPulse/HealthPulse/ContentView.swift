import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject private var store: HealthStore

    var body: some View {
        NavigationStack {
            Group {
                if store.authorized {
                    List {
                        MetricSection(title: "Steps", data: store.steps, format: "%.0f")
                        MetricSection(title: "Sleep (hours)", data: store.sleepHours, format: "%.1f")
                        MetricSection(title: "Resting heart rate (bpm)", data: store.restingHeartRate, format: "%.0f")
                    }
                    .refreshable { await store.refresh() }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.text.square").font(.system(size: 60)).foregroundStyle(.pink)
                        Text("See your last 7 days of steps, sleep and heart rate.")
                            .multilineTextAlignment(.center)
                        Button("Connect Apple Health") {
                            Task { await store.requestAccess() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("HealthPulse")
            .alert("Error", isPresented: .constant(store.errorMessage != nil)) {
                Button("OK") { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }
}

struct MetricSection: View {
    let title: String
    let data: [DailyValue]
    let format: String

    private var average: Double {
        let nonZero = data.filter { $0.value > 0 }
        return nonZero.isEmpty ? 0 : nonZero.map(\.value).reduce(0, +) / Double(nonZero.count)
    }

    var body: some View {
        Section(title) {
            Text("7-day average: \(String(format: format, average))")
                .font(.headline)
            Chart(data) { item in
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value(title, item.value)
                )
            }
            .frame(height: 160)
        }
    }
}
