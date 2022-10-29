//
//  ContentView.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var router: HomeRouter = HomeRouter()
    
    var body: some View {
        router.homeView()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
