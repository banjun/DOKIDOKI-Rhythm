import UIKit
import HealthKit
import Eureka
import NorthLayout
import Ikemen
import BrightFutures
import ReactiveSwift

private let store = HKHealthStore()

class ViewController: FormViewController {
    let activitiesSection = Section()

    init() {
        super.init(nibName: nil, bundle: nil)
        form +++ activitiesSection
    }

    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tabBarItem.title = "Playlists"
        navigationItem.title = "CINDERELLA GIRLS 5thLIVE TOUR"
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let typesToRead: [HKObjectType] = [.quantityType(forIdentifier: .heartRate)].compactMap {$0}

        store.requestAuthorization(toShare: nil, read: Set(typesToRead)) { granted, error in
            guard granted, error == nil else { NSLog("%@", "granted = \(granted), error = \(String(describing: error))"); return }
            self.healthStoreDidSetup()
        }
    }

    private func activities(title: String, start: Date, end: Date) -> Future<DokiDokiActivity, Never> {
        return .init { resolve in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])

            store.execute(HKAnchoredObjectQuery(type: HKSampleType.quantityType(forIdentifier: .heartRate)!, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
                NSLog("%@", "\(samples?.count ?? 0) samples found")
                guard let qSamples = samples as? [HKQuantitySample], qSamples.count > 0 else { return }

                let activity = DokiDokiActivity(title: title, start: start, heartbeats: qSamples.map { s in
                    DokiDokiActivity.TimedBeat(time: s.startDate, heartrate: Int(s.quantity.doubleValue(for: HKUnit(from: "count/min"))))
                })
//                NSLog("%@", "\(activities)")
//                let file =  URL(fileURLWithPath: NSHomeDirectory())
//                    .appendingPathComponent("Library")
//                    .appendingPathComponent(title)
//                    .appendingPathExtension("json")
//                try! (try! JSONEncoder().encode(activities)).write(to: file)
                resolve(.success(activity))
            })
        }
    }

    private func healthStoreDidSetup() {
        guard activitiesSection.isEmpty else { return }

        let periods: [(title: String, start: String, end: String)] = [
            ("宮城 Day1", "2017-05-13T17:00:00+0900", "2017-05-13T20:00:00+0900"),
            ("宮城 Day2", "2017-05-14T16:00:00+0900", "2017-05-14T19:00:00+0900"),
            ("石川 Day1", "2017-05-27T17:00:00+0900", "2017-05-27T20:00:00+0900"),
            ("石川 Day2", "2017-05-28T16:00:00+0900", "2017-05-28T19:00:00+0900"),
            ("大阪 Day1", "2017-06-09T18:00:00+0900", "2017-06-09T21:00:00+0900"),
            ("大阪 Day2", "2017-06-10T16:00:00+0900", "2017-06-10T19:00:00+0900"),
            ("静岡 Day1", "2017-06-24T17:00:00+0900", "2017-06-24T20:00:00+0900"),
            ("静岡 Day2", "2017-06-25T16:00:00+0900", "2017-06-25T19:00:00+0900"),
            ("幕張 Day1", "2017-07-08T17:00:00+0900", "2017-07-08T20:00:00+0900"),
            ("幕張 Day2", "2017-07-09T16:00:00+0900", "2017-07-09T19:00:00+0900"),
            ("福岡 Day1", "2017-07-29T16:30:00+0900", "2017-07-29T19:30:00+0900"),
            ("福岡 Day2", "2017-07-30T15:30:00+0900", "2017-07-30T18:30:00+0900"),
            ("SSA Day1", "2017-08-12T17:30:00+0900", "2017-08-12T22:30:00+0900"),
            ("SSA Day2", "2017-08-13T17:30:00+0900", "2017-08-13T22:30:00+0900")]

        SignalProducer<(title: String, start: String, end: String), Never>(periods)
            .map {($0.title, ISO8601DateFormatter().date(from: $0.start)!, ISO8601DateFormatter().date(from: $0.end)!)}
            .flatMap(.concat) { period in
                SignalProducer<DokiDokiActivity, Never> { observer, lifetime in
                    self.activities(title: period.0, start: period.1, end: period.2).onSuccess { a in
                        observer.send(value: a)
                        observer.sendCompleted()
                    }
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
//
//        let predicate = HKQuery.predicateForSamples(
//            withStart: ISO8601DateFormatter().date(from: "2017-08-13T17:16:00+0900"),
//            end: ISO8601DateFormatter().date(from: "2017-08-13T22:49:00+0900"),
//            options: [])
//
//        store.execute(HKAnchoredObjectQuery(type: HKSampleType.quantityType(forIdentifier: .heartRate)!, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
//            NSLog("%@", "\(samples?.count ?? 0) samples found")
//            guard let qSamples = samples as? [HKQuantitySample], qSamples.count > 0 else { return }
//
//            let head = qSamples//.prefix(upTo: 100)
//            head.forEach { s in
//                let date = s.startDate
//                let bpm = s.quantity.doubleValue(for: HKUnit(from: "count/min"))
//                let sourceRevision = s.sourceRevision
//                let device = s.device
//                print("\(date)\t\(bpm)\t\(sourceRevision.source.name) \(sourceRevision.version ?? "_") on \(device?.name ?? "_")")
//            }
//
//        })
    }
}
