import UIKit
import NorthLayout
import Ikemen

final class DokiDokiActivityViewController: UIViewController {
    let session: PlayerSession = PlayerSession()
    let activity: DokiDokiActivity
    let heartGraph = GraphView() ※ {$0.strokeColor = .systemPink}
    let audioGraph = GraphView() ※ {$0.strokeColor = .systemBlue}

    init(_ activity: DokiDokiActivity) {
        self.activity = activity
        super.init(nibName: nil, bundle: nil)
        title = activity.title
        navigationItem.largeTitleDisplayMode = .always
    }
    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        session.send(activity)

        let autolayout = northLayoutFormat([:], [
            "scroll": UIScrollView() ※ { sv in
                let autolayout = sv.northLayoutFormat([:], ["heart": heartGraph, "audio": audioGraph])
                autolayout("H:||[heart]||")
                autolayout("H:||[audio(==heart)]||")
                autolayout("V:|[heart(==128)]-[audio(==heart)]|")
            }])
        autolayout("H:|[scroll]|")
        autolayout("V:|[scroll]|")

        let dateInterval: DateInterval? = {
            let times = (activity.heartbeats.map {$0.time} + activity.audioLevels.map {$0.time})
            switch (times.min(), times.max()) {
            case (let min?, let max?): return DateInterval(start: min, end: max)
            default: return nil
            }
        }()
        heartGraph.data = (activity.heartbeats.map {($0.time, Double($0.heartrate))}, dateInterval)
        audioGraph.data = (activity.audioLevels.map {($0.time, $0.audioLevel)}, dateInterval)

        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(_:))) ※ { g in
            g.cancelsTouchesInView = false
            g.requiresExclusiveTouchType = false
            })
    }

    @objc private func panned(_ gesture: UIPanGestureRecognizer) {
        heartGraph.activateNodeInTouchLocation(gesture.location(in: heartGraph))
        audioGraph.activateNodeInTouchLocation(gesture.location(in: audioGraph))
    }
}
