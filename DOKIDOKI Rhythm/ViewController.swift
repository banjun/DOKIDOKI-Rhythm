import UIKit
import HealthKit

private let store = HKHealthStore()

class ViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {fatalError()}

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
