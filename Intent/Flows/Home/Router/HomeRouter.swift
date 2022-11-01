//
//  HomeRouter.swift
//  Intent
//
//  Created by Livsy on 29.10.2022.
//

import SwiftUI

final class HomeRouter: ObservableObject {
    
    // MARK: - Methods
    
    @ViewBuilder
    func homeView() -> some View {
        Home(router: self).preferredColorScheme(.dark)
    }
}

// For tabbar
struct HomeRouterView: View {
    @StateObject var router: HomeRouter = HomeRouter()
    
    var body: some View {
        NavigationView {
            self.router.homeView()
                .navigationTitle("Home")
        }
        .navigationViewStyle(.stack)
    }
}

extension HomeRouter: HomeScreenRouter {
    @ViewBuilder
    func addHabitScreen(viewModel: HabitViewModel) -> AddNewHabit {
        AddNewHabit(viewModel: viewModel)
    }
    
    func createTemplateScreen() -> CreateTemplateView {
        CreateTemplateView(viewModel: .init())
    }
}
