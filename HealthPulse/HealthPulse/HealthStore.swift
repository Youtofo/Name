import Foundation
import HealthKit

struct DailyValue: Identifiable {
    let date: Date
    let value: Double
    var id: Date { date }
}

@MainActor
final class HealthStore: ObservableObject {
    private let store = HKHealthStore()

    @Published var authorized = false
    @Published var errorMessage: String?
    @Published var steps: [DailyValue] = []
    @Published var restingHeartRate: [DailyValue] = []
    @Published var sleepHours: [DailyValue] = []

    private let readTypes: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.restingHeartRate),
        HKCategoryType(.sleepAnalysis),
    ]

    func requestAccess() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "Health data isn't available on this device."
            return
        }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            authorized = true
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh(days: Int = 7) async {
        do {
            steps = try await dailyStats(.stepCount, unit: .count(), options: .cumulativeSum, days: days)
            restingHeartRate = try await dailyStats(
                .restingHeartRate,
                unit: HKUnit.count().unitDivided(by: .minute()),
                options: .discreteAverage,
                days: days
            )
            sleepHours = try await dailySleep(days: days)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startDate(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -(days - 1), to: Calendar.current.startOfDay(for: .now))!
    }

    private func dailyStats(
        _ id: HKQuantityTypeIdentifier,
        unit: HKUnit,
        options: HKStatisticsOptions,
        days: Int
    ) async throws -> [DailyValue] {
        let start = startDate(days: days)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: HKQuantityType(id), predicate: predicate),
            options: options,
            anchorDate: start,
            intervalComponents: DateComponents(day: 1)
        )
        let collection = try await descriptor.result(for: store)
        var result: [DailyValue] = []
        collection.enumerateStatistics(from: start, to: .now) { stats, _ in
            let quantity = options.contains(.cumulativeSum) ? stats.sumQuantity() : stats.averageQuantity()
            result.append(DailyValue(date: stats.startDate, value: quantity?.doubleValue(for: unit) ?? 0))
        }
        return result
    }

    private func dailySleep(days: Int) async throws -> [DailyValue] {
        let start = startDate(days: days)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(
                type: HKCategoryType(.sleepAnalysis),
                predicate: HKQuery.predicateForSamples(withStart: start, end: .now)
            )],
            sortDescriptors: []
        )
        let samples = try await descriptor.result(for: store)
        let asleep = HKCategoryValueSleepAnalysis.allAsleepValues.map(\.rawValue)
        var totals: [Date: Double] = [:]
        for sample in samples where asleep.contains(sample.value) {
            // Attribute sleep to the day it ended (the morning you woke up).
            let day = Calendar.current.startOfDay(for: sample.endDate)
            totals[day, default: 0] += sample.endDate.timeIntervalSince(sample.startDate) / 3600
        }
        return (0..<days).map { offset in
            let day = Calendar.current.date(byAdding: .day, value: offset, to: start)!
            return DailyValue(date: day, value: totals[day] ?? 0)
        }
    }
}
