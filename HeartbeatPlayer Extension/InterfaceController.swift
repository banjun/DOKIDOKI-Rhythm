//
//  InterfaceController.swift
//  HeartbeatPlayer Extension
//
//  Created by BAN Jun on 2017/12/16.
//  Copyright © 2017 banjun. All rights reserved.
//

import Foundation
import HealthKit
import WatchConnectivity
import WatchKit
import Ikemen

class InterfaceController: WKInterfaceController {
    private var heartrate: Int?

    private let healthStore = HKHealthStore()
    private var hapticFeedbackTimer: Timer?
    private var workoutSession: HKWorkoutSession?
    private let playerSession: PlayerSession = PlayerSession()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }

    override func willActivate() {
        super.willActivate()
        playerSession.onActivity = { activity in
            self.heartrate = activity.heartbeats.map { $0.heartrate }.max()
            self.startWorkout()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func startWorkout() {
        stopWorkout()

        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other

        do {
            let session = try HKWorkoutSession(configuration: workoutConfiguration)
            session.delegate = self
            healthStore.start(session)
            self.workoutSession = session
        } catch {
            print(error)
        }
    }

    private func stopWorkout() {
        if let session = self.workoutSession {
            healthStore.end(session)
            self.workoutSession = nil
        }
    }

    @objc private func beat() {
        WKInterfaceDevice.current().play(.click)
    }
}

extension InterfaceController: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            hapticFeedbackTimer = Timer(timeInterval: 60.0/Double(heartrate ?? 1), target: self, selector: #selector(beat), userInfo: nil, repeats: true)
            RunLoop.main.add(hapticFeedbackTimer!, forMode: .default)
        default:
            hapticFeedbackTimer?.invalidate()
            hapticFeedbackTimer = nil
        }
    }
}
