//
//  HabitViewModel.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI
import CoreData
import UserNotifications

final class HabitViewModel: ObservableObject {
            
    ///New Habit Properties
    @Published var addNewHabit: Bool = false
    
    /// Editing Habit
    @Published var editHabit: Habit?
    
    @Published var title: String = ""
    @Published var habitColor: String = Colors.Card.raspberrySunset.rawValue
    @Published var weekDays: [String] = []
    @Published var isRemainderOn: Bool = false
    @Published var remainderText: String = ""
    @Published var remainderDate: Date = Date()
    @Published var remainderDates: [Date] = [Date()]
    @Published var createTemplate: Bool = false
    
    /// Remainder Time Picker
    @Published var showTimePicker: Bool = false
    @Published var timePickerIndex: Int = .zero
    
    /// Notification Access Status
    @Published var notificationAccess: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFull: Bool = false
    
    init() {
        requestNotificationAccess()
    }

    // MARK: Adding Habit to Database
    
    func addHabbit(context: NSManagedObjectContext) async -> Bool {
        
        // MARK: Editing Data
        
        let isEdit: Bool
        var habit: Habit
        
        if let editHabit = editHabit {
            habit = editHabit
            isEdit = true
            
            // Removing All Pending Notifications
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? [])
        } else {
            habit = Habit(context: context)
            isEdit = false
        }
        
        let newCount = (remainderDates.count * weekDays.count)
        var total = UserDefaults.standard.notificationsCount
                
        if isEdit {
            total -= (editHabit?.notificationDates?.count ?? 0) * (editHabit?.weekDays?.count ?? 0)
        }
        
        total += newCount
        
        isLoading = true
        UserDefaults.standard.notificationsCount = total
        
        guard total < 65 else {
            total -= newCount
            UserDefaults.standard.notificationsCount = total
            isFull = true
            isLoading = false
            return false
        }
        
        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekDays
        habit.isRemainderOn = isRemainderOn
        habit.remainderText = remainderText
        habit.dateAdded = Date()
        habit.notificationIDs = []
        habit.notificationDates = remainderDates
        
        if isRemainderOn {
            
            // MARK: Scheduling Notifications
            
            if let ids = try? await scheduleNotification() {
                habit.notificationIDs = ids
                if let _ = try? context.save() {
                    return true
                }
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
            }
        } else {
            
            // MARK: Adding Data
            
            if let _ = try? context.save() {
                return true
            }
        }
        
      return false
    }
    
    // MARK: Deleting Habit From Database
    
    func deleteHabit(context: NSManagedObjectContext) -> Bool {
        if let editHabit = editHabit {
            if editHabit.isRemainderOn {
                var total = UserDefaults.standard.notificationsCount
                total -= (editHabit.notificationDates?.count ?? 0) * (editHabit.weekDays?.count ?? 0)
                UserDefaults.standard.notificationsCount = total
                // Removing All Pending Notifications
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? [])
            }
            
            context.delete(editHabit)
            if let _ = try? context.save() {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Restoring Edit Data
    
    func restoreEditData() {
        if let editHabit = editHabit {
            title = editHabit.title ?? ""
            habitColor = editHabit.color ?? Colors.Card.raspberrySunset.rawValue
            weekDays = editHabit.weekDays ?? []
            isRemainderOn = editHabit.isRemainderOn
            remainderDates = editHabit.notificationDates ?? [Date()]
            remainderText = editHabit.remainderText ?? ""
        }
    }
    
    // MARK: Erasing Content
    
    func reset() {
        title = ""
        habitColor = Colors.Card.raspberrySunset.rawValue
        weekDays = []
        isRemainderOn = false
        remainderDates = [Date()]
        remainderText = ""
        editHabit = nil
        timePickerIndex = .zero
    }
    
    // MARK: Done Button Status
    
    func doneStatus() -> Bool {
        let remainderStatus = isRemainderOn ? remainderText == "" : false
        
        guard title.isEmpty || weekDays.isEmpty || remainderStatus else {
            return true
        }
        
        return false
    }
    
    // MARK: Adding Notifications
    
    private func scheduleNotification() async throws -> [String] {
        let content = UNMutableNotificationContent()
        content.title = "Intent"
        content.subtitle = remainderText
        content.sound = UNNotificationSound.default
        
        // Scheduled Ids
        var notificationIDs: [String] = []
        let calendar = Calendar.current
        let weekdaySymbols: [String] = calendar.shortWeekdaySymbols
        
        // MARK: Scheduling Notification
        
        for weekDay in weekDays {
            
            for date in remainderDates {
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
    
    
    private func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { status, _ in
            DispatchQueue.main.async {
                self.notificationAccess = status
            }
        }
    }
    
}
