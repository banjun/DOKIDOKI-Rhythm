import Foundation

struct DokiDokiActivity: Equatable, Codable {
    var title: String
    var start: Date
    var heartbeats: [TimedBeat]

    struct TimedBeat: Codable {
        var time: Date
        var heartrate: Int
    }

    static func == (lhs: Self, rhs: Self) -> Bool {return lhs.start == rhs.start}
}

let fakeActivities: [DokiDokiActivity] = [
    DokiDokiActivity(title: "宮城 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)]),
    DokiDokiActivity(title: "宮城 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)]),
    DokiDokiActivity(title: "宮城 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)]),
    DokiDokiActivity(title: "宮城 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)]),
    DokiDokiActivity(title: "宮城 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)]),
]
