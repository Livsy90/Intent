//
//  InteractiveBackgroundView.swift
//  Intent
//
//  Created by Livsy on 05.11.2022.
//

import SwiftUI

struct InteractiveBackgroundView: View {
        
    @GestureState var location: CGPoint = .zero
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let width = (size.width / 10)
            let itemCount = Int((size.height / width).rounded()) * 10

            LinearGradient(colors: [
                Colors.Card.plum.color, Colors.Card.blueRose.color, .indigo, .pink, Colors.Card.plum.color
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .mask {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 10), spacing: 0) {
                    ForEach(0..<itemCount, id: \.self) { _ in
                        GeometryReader { innerProxy in
                            let rect = innerProxy.frame(in: .named("GESTURE"))
                            let scale = itemScale(rect: rect, size: size)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.orange)
                                .scaleEffect(scale)
                        }
                        .padding(5)
                        .frame(height: width)
                    }
                }
            }
        }
        .padding(15)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($location, body: { value, out, _ in
                    out = value.location
                })
        )
        .coordinateSpace(name: "GESTURE")
        .preferredColorScheme(.dark)
        .animation(.easeInOut, value: location == .zero)
    }
    
    private func itemScale(rect: CGRect,size: CGSize) -> CGFloat {
        let a = location.x - rect.midX
        let b = location.y - rect.midY
        
        let root = sqrt((a * a) + (b * b))
        let diagonalValue = sqrt((size.width * size.width) + (size.height * size.height))
        
        let scale = root / (diagonalValue / 2)
        let modifiedScale = location == .zero ? 1 : (1 - scale)
                
        return modifiedScale > 0 ? modifiedScale : 0.001
    }
}

