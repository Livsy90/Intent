//
//  View+Adds.swift
//  Intent
//
//  Created by Livsy on 01.11.2022.
//

import SwiftUI

extension View {
    func glow(color: Color = .red, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
}
