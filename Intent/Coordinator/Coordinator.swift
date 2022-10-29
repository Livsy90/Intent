//
//  Coordinator.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI

enum HomeAssembly {
    static var view: some View {
        Home().preferredColorScheme(.dark)
    }
}

enum AddHabitAssembly {
    static var view: some View {
        AddNewHabit()
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
    }
    
    static func view(_ action: (() -> Void)?) -> some View {
        let viewModel = HabitViewModel()
        viewModel.onAddHabit = {
            action?()
        }
        let view = AddNewHabit()
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
        
        return view
    }
}

class HomeCoordinator {
  
    enum Destination {
        case home
        case addHabit
    }
    
    func start() -> some View {
        HomeAssembly.view
    }
    
    func goTo(_ destination: Destination) -> some View {
        switch destination {
        case .home:
            return AnyView(HomeAssembly.view)
        case .addHabit:
            let view = AddHabitAssembly.view {
                print("here")
            }
            return AnyView(view)
        }
    }
    
}
