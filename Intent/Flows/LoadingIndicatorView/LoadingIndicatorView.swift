//
//  LoadingIndicatorView.swift
//  Intent
//
//  Created by Livsy on 04.11.2022.
//

import SwiftUI

struct LoadingIndicatorView: View {
    
    // @Environment(\.colorScheme) var scheme
    
    @Binding var showPopup : Bool
    @State var animateBall = false
    @State var animateRotation = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Colors.Background.semiDark)
                .frame(width: 40, height: 40)
                .rotation3DEffect(
                    .init(degrees: 60),
                    axis: (x: 1, y: 0, z: 0.0),
                    anchor: .center,
                    anchorZ: 0.0,
                    perspective: 1.0
                )
                .offset(y: 35)
                .opacity(animateBall ? 1 : 0)
            
            Circle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Colors.Card.plum.color, Colors.Card.blueRose.color]), startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.init(degrees: animateRotation ? 360 : 0))
                .offset(y: animateBall ? 10 : -25)
            
        }
        .onAppear(perform: {
            doAnimation()
        })
    }
    
    func doAnimation() {
        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
            animateBall.toggle()
        }
        
        withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
            animateRotation.toggle()
        }
    }
}

