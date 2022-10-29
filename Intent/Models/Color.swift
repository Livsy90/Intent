//
//  Color.swift
//  Intent
//
//  Created by Livsy on 29.10.2022.
//

import UIKit

enum Colors {
    
    enum Card: String, CaseIterable {
        case blueRose
        case creamDonut
        case forgetMeNot
        case latte
        case overcast
        case raspberrySunset
        case youngLeaf
        
        var index: Int {
            switch self {
            case .raspberrySunset:
                return 1
            case .creamDonut:
                return 2
            case .forgetMeNot:
                return 3
            case .latte:
                return 4
            case .overcast:
                return 5
            case .blueRose:
                return 6
            case .youngLeaf:
                return 7
            }
        }
        
        static func color(for index: Int) -> String {
            allCases
                .filter { $0.index == index }
                .first?.rawValue ?? self.raspberrySunset.rawValue
        }
    }
    
}
