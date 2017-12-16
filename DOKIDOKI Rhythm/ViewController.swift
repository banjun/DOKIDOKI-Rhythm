import UIKit
import HealthKit
import Eureka
import NorthLayout
import Ikemen

private let store = HKHealthStore()

final class PlaylistCell: Cell<DokiDokiActivity>, CellType {
    let titleLabel = UILabel() ※ {
        $0.font = .boldSystemFont(ofSize: 18)
    }
    let dateLabel = UILabel() ※ { (l: UILabel) in
        l.font = .systemFont(ofSize: 14)
        l.textColor = .gray
    }
    let heartLabel = UILabel() ※ { (l: UILabel) in
        l.font = .boldSystemFont(ofSize: 16)
        l.textColor = .magenta
    }

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func setup() {
        let autolayout = contentView.northLayoutFormat([:], [
            "title": titleLabel,
            "date": dateLabel,
            "heart": heartLabel])
        autolayout("H:||[title]-[heart]||")
        autolayout("H:||[date]-[heart]||")
        autolayout("V:||[title]-[date]||")
        autolayout("V:||[heart]||")
        heartLabel.setContentHuggingPriority(.required, for: .horizontal)

        selectionStyle = .default
    }

    override func update() {
        titleLabel.text = row.value?.title
        dateLabel.text = row.value.map {(DateFormatter() ※ {$0.dateFormat = "yyyy-mm-dd HH:mm -"}).string(from: $0.start)}
        heartLabel.text = "💓" + ("\(row.value?.heartbeats.map {$0.heartrate}.max().map {String($0)} ?? "---")")
    }
}

final class PlaylistRow: Row<PlaylistCell>, RowType {
    required init(tag: String?) {super.init(tag: tag)}
}

final class DokiDokiActivityViewController: UIViewController {
    let activity: DokiDokiActivity
    init(_ activity: DokiDokiActivity) {
        self.activity = activity
        super.init(nibName: nil, bundle: nil)
        title = activity.title
        navigationItem.largeTitleDisplayMode = .always
    }
    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

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
