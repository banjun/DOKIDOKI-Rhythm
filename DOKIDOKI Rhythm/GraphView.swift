import UIKit
import Ikemen

final class GraphView: UIView {
    var data: (series: [(date: Date, value: Double)], dateInterval: DateInterval?) = ([], nil) {
        didSet { redraw() }
    }
    private var minDate: TimeInterval? {data.dateInterval?.start.timeIntervalSince1970 ?? (data.series.map {$0.date.timeIntervalSince1970}.min())}
    private var maxDate: TimeInterval? {data.dateInterval?.end.timeIntervalSince1970 ?? (data.series.map {$0.date.timeIntervalSince1970}.max())}

    var strokeColor: UIColor = .systemBlue {
        didSet { redraw() }
    }

    private var layers: [CAShapeLayer] = [] {
        didSet {
            oldValue.forEach {$0.removeFromSuperlayer()}
            layers.forEach {layer.addSublayer($0)}
        }
    }

    private var activeLayer: CAShapeLayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            if let newValue = activeLayer {
                layer.addSublayer(newValue)
            }
        }
    }

    private var lastFrame: CGRect = .zero

    init() {
        super.init(frame: .zero)
//        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(_:))) ※ { g in
//            g.cancelsTouchesInView = false
//            g.requiresExclusiveTouchType = false
//            })
    }

    required init?(coder: NSCoder) {fatalError()}

    func redraw() {
        guard let minDate = self.minDate,
            let minValue = (data.series.map {$0.value}.min()),
            let maxDate = self.maxDate,
            let maxValue = (data.series.map {$0.value}.max()) else {
                layers.removeAll()
                return
        }

        layers = data.series.map { date, value in
            CAShapeLayer() ※ { l in
                l.strokeColor = strokeColor.cgColor
                l.fillColor = UIColor.systemBackground.cgColor
                let radius: Double = 0.5
                let nodeRect = CGRect(
                    x: (date.timeIntervalSince1970 - minDate) / (maxDate - minDate) * Double(bounds.width) - radius,
                    y: (1 - ((value - minValue) / (maxValue - minValue))) * Double(bounds.height) - radius,
                    width: radius * 2,
                    height: radius * 2)
                l.path = UIBezierPath(ovalIn: nodeRect).cgPath
            }
        }

        lastFrame = bounds
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds != lastFrame {
            redraw()
        }
    }

    @objc private func panned(_ gesture: UIPanGestureRecognizer) {
        let p = gesture.location(in: self)
        activateNodeInTouchLocation(p)
    }
    func activateNodeInTouchLocation(_ p: CGPoint) {
        guard let minDate = self.minDate,
            let maxDate = self.maxDate else { return }
        let x = Double(p.x / bounds.width) * (maxDate - minDate) + minDate

        let nearest = data.series.min { a,  b in
            abs(a.date.timeIntervalSince1970 - x) < abs(b.date.timeIntervalSince1970 - x)
        }
        NSLog("%@", "\(String(describing: nearest))")
    }
}
