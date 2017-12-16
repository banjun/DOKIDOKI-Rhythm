import UIKit
import NorthLayout
import Ikemen

final class DokiDokiActivityViewController: UIViewController {
    let session: PlayerSession = PlayerSession()
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
        session.send(activity)
    }
}
