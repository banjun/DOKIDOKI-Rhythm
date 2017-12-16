import Eureka
import Ikemen

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
        dateLabel.text = row.value.map {(DateFormatter() ※ {$0.dateFormat = "yyyy-MM-dd HH:mm -"}).string(from: $0.start)}
        heartLabel.text = "💓" + ("\(row.value?.heartbeats.map {$0.heartrate}.max().map {String($0)} ?? "---")")
    }
}

final class PlaylistRow: Row<PlaylistCell>, RowType {
    required init(tag: String?) {super.init(tag: tag)}
}
