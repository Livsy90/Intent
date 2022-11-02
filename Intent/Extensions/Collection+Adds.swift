//
//  Collection+Adds.swift
//  Intent
//
//  Created by Livsy on 03.11.2022.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
