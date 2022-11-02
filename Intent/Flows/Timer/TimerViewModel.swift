//
//  PomodoroModel.swift
//  Intent
//
//  Created by Livsy on 02.11.2022.
//

import SwiftUI

final class TimerViewModel: NSObject, ObservableObject {
    
    @Published var progress: CGFloat = 1
    @Published var timerStringValue: String = "00:00"
    @Published var isStarted: Bool = false
    @Published var addNewTimer: Bool = false
    
    @Published var hour: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    
    // MARK: Total Seconds
    @Published var totalSeconds: Int = 0
    @Published var staticTotalSeconds: Int = 0
    @Published var isFinished: Bool = false

    func startTimer(){
        withAnimation(.easeInOut(duration: 0.25)){isStarted = true}
        // MARK: Setting String Time Value
        timerStringValue = "\(hour == 0 ? "" : "\(hour):")\(minutes >= 10 ? "\(minutes)":"0\(minutes)"):\(seconds >= 10 ? "\(seconds)":"0\(seconds)")"
        // MARK: Calculating Total Seconds For Timer Animation
        totalSeconds = (hour * 3600) + (minutes * 60) + seconds
        staticTotalSeconds = totalSeconds
        addNewTimer = false
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
    }
        
    func updateTimer() {
        if totalSeconds > 0{
            totalSeconds -= 1
        }
        progress = CGFloat(totalSeconds) / CGFloat(staticTotalSeconds)
        progress = (progress < 0 ? 0 : progress)
        
        // 60 Minutes * 60 Seconds
        hour = totalSeconds / 3600
        minutes = (totalSeconds / 60) % 60
        seconds = (totalSeconds % 60)
        timerStringValue = "\(hour == 0 ? "" : "\(hour):")\(minutes >= 10 ? "\(minutes)":"0\(minutes)"):\(seconds >= 10 ? "\(seconds)":"0\(seconds)")"
        if hour == 0 && seconds == 0 && minutes == 0 {
            isStarted = false
            isFinished = true
            
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
    
}

