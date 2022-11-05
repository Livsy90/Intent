//
//  PomodoroModel.swift
//  Intent
//
//  Created by Livsy on 02.11.2022.
//

import SwiftUI

final class TimerViewModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    @Published var progress: CGFloat = 1
    @Published var timerStringValue: String = "00:00"
    @Published var isStarted: Bool = false
    @Published var addNewTimer: Bool = false
    
    @Published var hour: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    
    @Published var totalSeconds: Int = 0
    @Published var staticTotalSeconds: Int = 0
    @Published var isFinished: Bool = false
    @Published var isShowWarning: Bool = false
    
    private var id = ""
    
    override init() {
        super.init()
        self.authorizeNotification()
    }
    
    func authorizeNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { _, _ in }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
        ) -> Void)
    {
        completionHandler([.sound,.banner])
    }

    func startTimer() async {
        withAnimation(.easeInOut(duration: 0.25)){isStarted = true}
        // MARK: Setting String Time Value
        timerStringValue = "\(hour == 0 ? "" : "\(hour):")\(minutes >= 10 ? "\(minutes)":"0\(minutes)"):\(seconds >= 10 ? "\(seconds)":"0\(seconds)")"
        totalSeconds = (hour * 3600) + (minutes * 60) + seconds
        staticTotalSeconds = totalSeconds
        addNewTimer = false
        try? await addNotification()
    }
        
    func stopTimer() {
        withAnimation{
            isStarted = false
            hour = 0
            minutes = 0
            seconds = 0
            progress = 1
        }
        totalSeconds = 0
        staticTotalSeconds = 0
        timerStringValue = "00:00"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
        
    func updateTimer() {
        if totalSeconds > 0{
            totalSeconds -= 1
        }
        progress = CGFloat(totalSeconds) / CGFloat(staticTotalSeconds)
        progress = (progress < 0 ? 0 : progress)
        
        hour = totalSeconds / 3600
        minutes = (totalSeconds / 60) % 60
        seconds = (totalSeconds % 60)
        timerStringValue = "\(hour == 0 ? "" : "\(hour):")\(minutes >= 10 ? "\(minutes)":"0\(minutes)"):\(seconds >= 10 ? "\(seconds)":"0\(seconds)")"
        if hour == 0 && seconds == 0 && minutes == 0 {
            isStarted = false
            isFinished = true
        }
    }
    
    private func addNotification() async throws {
        guard let total = try? await notificationsCount() else { return }
        
        guard total < 64 else {
            isShowWarning = true
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Intent"
        content.subtitle = "The time has come"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "notificationSound.wav"))
        id = UUID().uuidString
        
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(staticTotalSeconds), repeats: false)
        )
        
        try await UNUserNotificationCenter.current().add(request)
    }
    
    private func notificationsCount() async throws -> Int {
        let notificationCenter = UNUserNotificationCenter.current()
        let notificationRequests = await notificationCenter.pendingNotificationRequests()
        return notificationRequests.count
    }
    
}

