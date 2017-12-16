import UIKit
import HealthKit
import Eureka
import NorthLayout
import Ikemen
import BrightFutures
import Result

private let store = HKHealthStore()

class ViewController: FormViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
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

        let typesToRead: [HKObjectType] = [.quantityType(forIdentifier: .heartRate)].flatMap {$0}

        store.requestAuthorization(toShare: nil, read: Set(typesToRead)) { granted, error in
            guard granted, error == nil else { NSLog("%@", "granted = \(granted), error = \(String(describing: error))"); return }
            self.healthStoreDidSetup()
        }
    }

    private func activities(title: String, start: Date, end: Date) -> Future<DokiDokiActivity, NoError> {
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
        let futures: [Future<DokiDokiActivity, NoError>] = [
            activities(title: "SSA Day1",
                       start: ISO8601DateFormatter().date(from: "2017-08-12T17:30:00+0900")!,
                       end: ISO8601DateFormatter().date(from: "2017-08-12T22:30:00+0900")!),
            activities(title: "SSA Day2",
                       start: ISO8601DateFormatter().date(from: "2017-08-13T17:30:00+0900")!,
                       end: ISO8601DateFormatter().date(from: "2017-08-13T22:30:00+0900")!),
            ]
        futures.sequence()
            .onSuccess(DispatchQueue.main.context) { activities in
                self.form +++ Section {
                    $0.append(contentsOf: activities.map {a in PlaylistRow {
                        $0.value = a
                        $0.onCellSelection { [weak self] _, _ in
                            DispatchQueue.main.async {
                                let vc = DokiDokiActivityViewController(a)
                                self?.show(vc, sender: nil)
                            }
                        }
                        }})
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
