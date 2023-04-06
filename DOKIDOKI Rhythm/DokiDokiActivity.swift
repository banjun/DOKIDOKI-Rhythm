import Foundation

struct DokiDokiActivity: Equatable, Codable {
    var title: String
    var start: Date
    var heartbeats: [TimedBeat]
    var audioLevels: [AudioLevel]

    struct TimedBeat: Codable {
        var time: Date
        var heartrate: Int
    }

    struct AudioLevel: Codable {
        var time: Date
        var audioLevel: Double
    }

    static func == (lhs: DokiDokiActivity, rhs: DokiDokiActivity) -> Bool {return lhs.start == rhs.start}
}

let fakeActivities: [DokiDokiActivity] = [
    DokiDokiActivity(title: "宮城 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "宮城 Day2", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "石川 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "石川 Day2", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "大阪 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "大阪 Day2", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "静岡 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "静岡 Day2", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "幕張 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "幕張 Day2", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "福岡 Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "福岡 Day2", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "SSA Day1", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
    DokiDokiActivity(title: "SSA Day2", start: Date(), heartbeats: [DokiDokiActivity.TimedBeat(time: Date(), heartrate: 215)], audioLevels: []),
]
