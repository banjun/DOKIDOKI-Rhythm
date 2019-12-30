import UIKit
import HealthKit
import Eureka
import NorthLayout
import Ikemen
import BrightFutures
import ReactiveSwift

private let store = HKHealthStore()

class Cinderella6thViewController: FormViewController {
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
        navigationItem.title = "CINDERELLA GIRLS 6thLIVE TOUR"
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func activities(title: String, start: Date, end: Date) -> Future<DokiDokiActivity, Never> {
        return .init { resolve in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])

            store.execute(HKAnchoredObjectQuery(type: HKSampleType.quantityType(forIdentifier: .heartRate)!, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
                NSLog("%@", "\(samples?.count ?? 0) samples found")
                guard let qSamples = samples as? [HKQuantitySample], qSamples.count > 0 else { return }

                let activity = DokiDokiActivity(title: title, start: start, heartbeats: qSamples.map { s in
                    DokiDokiActivity.TimedBeat(time: s.startDate, heartrate: Int(s.quantity.doubleValue(for: HKUnit(from: "count/min"))))
                }, audioLevels: [])
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

    private func setupHealthStore() {
        let typesToRead: [HKObjectType] = [.quantityType(forIdentifier: .heartRate)].compactMap {$0}

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
            ("メットライフドーム Day1", "2018-11-10T16:00:00+0900", "2018-11-10T20:00:00+0900"),
            ("メットライフドーム Day2", "2018-11-11T16:00:00+0900", "2018-11-11T20:00:00+0900"),
            ("ナゴヤドーム Day1", "2018-12-01T16:00:00+0900", "2018-12-01T20:00:00+0900"),
            ("ナゴヤドーム Day2", "2018-12-02T16:00:00+0900", "2018-12-02T20:00:00+0900")]

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
