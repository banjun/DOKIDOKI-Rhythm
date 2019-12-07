import UIKit
import Ikemen

final class GraphView: UIView {
    var data: (series: [(date: Date, value: Double)], dateInterval: DateInterval?) = ([], nil) {
        didSet { redraw() }
    }

    var strokeColor: UIColor = .systemBlue {
        didSet { redraw() }
    }

    private var layers: [CAShapeLayer] = [] {
        didSet {
            oldValue.forEach {$0.removeFromSuperlayer()}
            layers.forEach {layer.addSublayer($0)}
        }
    }

    private var lastFrame: CGRect = .zero

    func redraw() {
        guard let minDate = data.dateInterval?.start.timeIntervalSince1970 ?? (data.series.map {$0.date.timeIntervalSince1970}.min()),
            let minValue = (data.series.map {$0.value}.min()),
            let maxDate = data.dateInterval?.end.timeIntervalSince1970 ?? (data.series.map {$0.date.timeIntervalSince1970}.max()),
            let maxValue = (data.series.map {$0.value}.max()) else {
                layers.removeAll()
                return
        }

        layers = data.series.map { date, value in
            CAShapeLayer() ※ { l in
                l.strokeColor = strokeColor.cgColor
                l.fillColor = UIColor.systemBackground.cgColor
                let radius: Double = 1
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
}
