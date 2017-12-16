import UIKit
import HealthKit
import Eureka
import NorthLayout
import Ikemen

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

        form +++ Section {
            $0.append(contentsOf: fakeActivities.map {a in PlaylistRow {
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let typesToRead: [HKObjectType] = [.quantityType(forIdentifier: .heartRate)].flatMap {$0}

        store.requestAuthorization(toShare: nil, read: Set(typesToRead)) { granted, error in
            guard granted, error == nil else { NSLog("%@", "granted = \(granted), error = \(String(describing: error))"); return }
            self.healthStoreDidSetup()
        }
    }

    private func healthStoreDidSetup() {
        store.execute(HKAnchoredObjectQuery(type: HKSampleType.quantityType(forIdentifier: .heartRate)!, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
            NSLog("%@", "\(samples?.count ?? 0) samples found")
            guard let qSamples = samples as? [HKQuantitySample], qSamples.count > 0 else { return }

            let head = qSamples.prefix(upTo: 100)
            head.forEach { s in
                let date = s.startDate
                let bpm = s.quantity.doubleValue(for: HKUnit(from: "count/min"))
                let sourceRevision = s.sourceRevision
                let device = s.device
                print("\(date)\t\(bpm)\t\(sourceRevision.source.name) \(sourceRevision.version ?? "_") on \(device?.name ?? "_")")
            }
        })
    }
}
