//
//  CreateTemplateViewModel.swift
//  Intent
//
//  Created by Livsy on 30.10.2022.
//

import SwiftUI
import CoreData
import UserNotifications

final class CreateTemplateViewModel: ObservableObject {
            
    ///New Habit Properties
    @Published var addNewHabit: Bool = false
    @Published var addNewTemplate: Bool = false
    @Published var step: Step = .hour
    
    /// Editing Habit
    @Published var editHabit: Habit?
    
    @Published var title: String = ""
    @Published var habitColor: String = Colors.Card.raspberrySunset.rawValue
    @Published var remainderText: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    
    
    /// Remainder Time Picker
    @Published var showStartTimePicker: Bool = false
    @Published var showEndTimePicker: Bool = false

    
    /// Notification Access Status
    @Published  var notificationAccess: Bool = false
    
    init() {
        requestNotificationAccess()
    }

    // MARK: Adding Habit to Database
    
    func addHabbit(context: NSManagedObjectContext) async -> Bool {
        let habit = Habit(context: context)
        let weekDays = Calendar.current.shortWeekdaySymbols
        let dates = datesBetween(startDate: startDate, endDate: endDate, step: step)
        
        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekDays
        habit.isRemainderOn = true
        habit.remainderText = remainderText
        habit.dateAdded = Date()
        habit.notificationIDs = []
        habit.notificationDates = dates
        
        if let ids = try? await scheduleNotification(dates: dates) {
            habit.notificationIDs = ids
            if let _ = try? context.save() {
                return true
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
        
      return false
    }
    
    // MARK: Done Button Status
    
    func doneStatus() -> Bool {
        !title.isEmpty && startDate < endDate && !remainderText.isEmpty
    }
    
    private func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound,.alert]) { status, _ in
            DispatchQueue.main.async {
                self.notificationAccess = status
            }
        }
    }
    
    private func datesBetween(
        startDate: Date,
        endDate: Date,
        step: Step
    ) -> [Date] {
        
        var date = startDate
        var dates = [Date]()

        while date <= endDate {
            date = Calendar.current.date(
                byAdding: step.calendar.component,
                value: step.calendar.value,
                to: date
            ) ?? Date()
            
            dates.append(date)
        }
        
        return dates
    }
    
    // MARK: Adding Notifications
    
    private func scheduleNotification(dates: [Date]) async throws -> [String] {
        let content = UNMutableNotificationContent()
        content.title = "Intent"
        content.subtitle = remainderText
        content.sound = UNNotificationSound.default
        
        // Scheduled Ids
        var notificationIDs: [String] = []
        let calendar = Calendar.current
        let weekdaySymbols: [String] = calendar.shortWeekdaySymbols
        
        // MARK: Scheduling Notification
        
        for weekDay in Calendar.current.shortWeekdaySymbols {
            
            for date in dates {
                let id = UUID().uuidString
                let hour = calendar.component(.hour, from: date)
                let min = calendar.component(.minute, from: date)
                let day = weekdaySymbols.firstIndex { currentDay in
                    return currentDay == weekDay
                } ?? -1
                
                if day != -1 {
                    var components = DateComponents()
                    components.hour = hour
                    components.minute = min
                    components.weekday = day + 1
                    
                    // MARK: Thus this will Trigger Notification on Each Selected Day
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                    
                    // MARK: Notification Request
                    
                    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                    
                    // ADDING ID
                    notificationIDs.append(id)
                    
                    try await UNUserNotificationCenter.current().add(request)
                }
            }
        }
        
        return notificationIDs
    }
    
}
