import Eureka
import Ikemen

final class PlaylistCell: Cell<DokiDokiActivity>, CellType {
    let titleLabel = UILabel() ※ {
        $0.font = .boldSystemFont(ofSize: 18)
    }
    let dateLabel = UILabel() ※ { l in
        l.font = .systemFont(ofSize: 14)
        l.textColor = .gray
    }
    let heartLabel = UILabel() ※ { l in
        l.font = .boldSystemFont(ofSize: 16)
        l.textColor = .systemPink
    }
    let audioLevelLabel = UILabel() ※ { l in
        l.font = .boldSystemFont(ofSize: 16)
        l.textColor = .systemBlue
    }
    let heartGraph = GraphView() ※ {
        $0.strokeColor = .systemPink
    }
    let audioLevelGraph = GraphView() ※ {
        $0.strokeColor = .systemBlue
    }

    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {fatalError()}

    override func setup() {
        let autolayout = contentView.northLayoutFormat([:], [
            "title": titleLabel,
            "date": dateLabel,
            "heart": heartLabel,
            "audio": audioLevelLabel,
            "heartGraph": heartGraph,
            "audioGraph": audioLevelGraph])
        autolayout("H:||[title]-(>=8)-[heart]||")
        autolayout("H:||[title]-(>=8)-[audio]||")
        autolayout("H:||[date]-(>=8)-[heart]||")
        autolayout("H:||[date]-(>=8)-[audio]||")
        autolayout("H:||[heartGraph]||")
        autolayout("H:||[audioGraph]||")
        autolayout("V:||[title]-[date]-(>=8)-[heartGraph(==48)]-[audioGraph(==48)]||")
        autolayout("V:||[heart]-[audio(==heart)]-(>=8)-[heartGraph]")
        heartLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        audioLevelLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        selectionStyle = .default
    }

    override func update() {
        let value = row.value

        titleLabel.text = value?.title
        dateLabel.text = value.map {(DateFormatter() ※ {$0.dateFormat = "yyyy-MM-dd HH:mm -"; $0.locale = Locale(identifier: "en_US_POSIX")}).string(from: $0.start)}

        let heartrates = value?.heartbeats.map {$0.heartrate}
        let audioLevels = value?.audioLevels.map {$0.audioLevel} ?? []
        let audioLevelInterval = [audioLevels.min(), audioLevels.max()].compactMap {$0}.map {String(Int(round($0)))}.joined(separator: " - ")

        heartLabel.text = "💓" + ("\(heartrates?.max().map {"\($0) bpm"} ?? "---")")
        audioLevelLabel.text = "🔊" + (!audioLevelInterval.isEmpty ? (audioLevelInterval + " dB") : "---")

        heartGraph.data = (value?.heartbeats.map {($0.time, Double($0.heartrate))} ?? [], nil)
        audioLevelGraph.data = (value?.audioLevels.map {($0.time, Double($0.audioLevel))} ?? [], nil)
    }
}

final class PlaylistRow: Row<PlaylistCell>, RowType {
    required init(tag: String?) {super.init(tag: tag)}
}
