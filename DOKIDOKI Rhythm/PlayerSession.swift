//
//  PlayerSession.swift
//  DOKIDOKI Rhythm
//
//  Created by mzp on 2017/12/16.
//  Copyright © 2017 banjun. All rights reserved.
//

import Foundation
import WatchConnectivity

class PlayerSession: NSObject {
    private lazy var session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.default
        } else {
            return nil
        }
    }()

    override init() {
        super.init()
        session?.delegate = self
        session?.activate()
    }

    func send(_ activity: DokiDokiActivity) {
        guard let session = session else { return }

        let data = try! JSONEncoder().encode(activity)
        let message = [
            "activity": data
        ]
        if session.isReachable {
            session.sendMessage(message, replyHandler: { _ in }, errorHandler: nil)
        }
    }
}

extension PlayerSession: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }
#endif

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        NSLog("\(message)")
        if let data = message["activity"] as? Data {
            let activity = try! JSONDecoder().decode(DokiDokiActivity.self, from: data)
            NSLog("\(activity)")
        }
    }
}
