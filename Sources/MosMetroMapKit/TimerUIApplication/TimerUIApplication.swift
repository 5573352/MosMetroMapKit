//
//  TimerUIApplication.swift
//
//  Created by Кузин Павел on 29.09.2021.
//

import UIKit

public class TimerUIApplication : UIApplication {

    static let ApplicationDidTimoutNotification = "AppTimout"

    var idleTimer: Timer?

    // Listen for any touch. If the screen receives a touch, the timer is reset.
    public override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        if event.allTouches?.contains(where: { $0.phase == .began || $0.phase == .moved }) == true {
            resetIdleTimer()
        }
    }

    // Resent the timer because there was user interaction.
    func resetIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(
            timeInterval : MapKit.shared.timeoutInSeconds,
            target       : self,
            selector     : #selector(MapKit.closeMetro),
            userInfo     : nil,
            repeats      : false
        )
    }

    // If the timer reaches the limit as defined in timeoutInSeconds, post this notification.
    func idleTimerExceeded() {
        Foundation.NotificationCenter.default.post(name: NSNotification.Name(rawValue: TimerUIApplication.ApplicationDidTimoutNotification), object: nil)
    }
}
