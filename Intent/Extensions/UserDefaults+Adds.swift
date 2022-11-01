//
//  UserDefaults+Adds.swift
//  Intent
//
//  Created by Livsy on 01.11.2022.
//

import Foundation

extension UserDefaults {
    
    private enum Key {
        static let notificationsCount = "notificationsCount"
    }
    
    var notificationsCount: Int {
        get {
            return integer(forKey: Key.notificationsCount)
        }
        set {
            set(newValue, forKey: Key.notificationsCount)
        }
    }
    
}

