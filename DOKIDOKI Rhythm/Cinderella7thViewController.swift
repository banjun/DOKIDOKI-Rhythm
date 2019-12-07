import UIKit
import HealthKit
import Eureka
import NorthLayout
import Ikemen
import BrightFutures
import ReactiveSwift

private let store = HKHealthStore()

class Cinderella7thViewController: FormViewController {
    let actionSection = Section()
    let activitiesSection = Section()

    init() {
        super.init(nibName: nil, bundle: nil)
        form
            +++ actionSection
            <<< ButtonRow {
                $0.title = "Fetch"
                $0.onCellSelection { [weak self] _, _ in
                    self?.setupHealthStore()
                }
            }
            +++ activitiesSection
    }

    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "CINDERELLA GIRLS 7thLIVE TOUR"
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func noises(start: Date, end: Date) -> SignalProducer<(HKQuantity, DateInterval), Never> {
        .init { observer, _ in
            store.execute(HKQuantitySeriesSampleQuery(
                quantityType: HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,
                predicate: HKQuery.predicateForSamples(withStart: start, end: end, options: [])) { (query, quantity, interval, sample, done, error) in
                    if let quantity = quantity, let interval = interval {
                        observer.send(value: (quantity, interval))
                    }
                    if done {
                        observer.sendCompleted()
                    }
            })
        }
    }

    private func heartbeats(start: Date, end: Date) -> SignalProducer<(HKQuantity, DateInterval), Never> {
        .init { observer, _ in
            store.execute(HKQuantitySeriesSampleQuery(
                quantityType: HKObjectType.quantityType(forIdentifier: .heartRate)!,
                predicate: HKQuery.predicateForSamples(withStart: start, end: end, options: [])) { (query, quantity, interval, sample, done, error) in
                    if let quantity = quantity, let interval = interval {
                        observer.send(value: (quantity, interval))
                    }
                    if done {
                        observer.sendCompleted()
                    }
            })
        }
    }

    private func setupHealthStore() {
        let typesToRead: [HKObjectType] = [.quantityType(forIdentifier: .heartRate), .quantityType(forIdentifier: .environmentalAudioExposure)].compactMap {$0}

        store.requestAuthorization(toShare: nil, read: Set(typesToRead)) { granted, error in
            guard granted, error == nil else { NSLog("%@", "granted = \(granted), error = \(String(describing: error))"); return }
            self.healthStoreDidSetup()
        }

        actionSection.first?.disabled = true
        actionSection.first?.evaluateDisabled()
    }

    private func healthStoreDidSetup() {
        guard activitiesSection.isEmpty else { return }

        let periods: [(title: String, start: String, end: String)] = [
            ("千葉 Day1", "2019-09-03T18:00:00+0900", "2019-09-03T22:00:00+0900"),
            ("千葉 Day2", "2019-09-04T18:00:00+0900", "2019-09-04T22:00:00+0900"),
            ("名古屋 Day1", "2019-11-09T17:00:00+0900", "2019-11-09T21:00:00+0900"),
            ("名古屋 Day2", "2019-11-10T16:00:00+0900", "2019-11-10T20:00:00+0900"),
            ("大阪 Day1", "2020-02-15T17:00:00+0900", "2020-02-15T21:00:00+0900"),
            ("大阪 Day2", "2020-02-16T16:00:00+0900", "2020-02-16T20:00:00+0900")]

        SignalProducer<(title: String, start: String, end: String), Never>(periods)
            .map {($0.title, ISO8601DateFormatter().date(from: $0.start)!, ISO8601DateFormatter().date(from: $0.end)!)}
            .flatMap(.concat) { period in
                self.heartbeats(start: period.1, end: period.2).collect()
                    .zip(with: self.noises(start: period.1, end: period.2).collect())
                    .map { heartbeats, noises -> DokiDokiActivity in
                        NSLog("%@", "found heartbeat quantities: \(heartbeats.count) for \(period.0)")
                        NSLog("%@", "found audio level quantities: \(noises.count) for \(period.0)")
                        return DokiDokiActivity(
                            title: period.0,
                            start: period.1,
                            heartbeats: heartbeats.map { q, interval in
                                DokiDokiActivity.TimedBeat(time: interval.start, heartrate: Int(q.doubleValue(for: HKUnit(from: "count/min"))))
                            },
                            audioLevels: noises.map { q, interval in
                                DokiDokiActivity.AudioLevel(time: interval.start, audioLevel: q.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()))
                        })
                }
        }.observe(on: QueueScheduler.main).startWithValues { a in
            self.activitiesSection <<< PlaylistRow {
                $0.value = a
                $0.onCellSelection { [weak self] _, _ in
                    DispatchQueue.main.async {
                        let vc = DokiDokiActivityViewController(a)
                        self?.show(vc, sender: nil)
                    }
                }
            }
        }
    }
}
