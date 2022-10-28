//
//  ContentView.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
