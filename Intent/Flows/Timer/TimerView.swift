//
//  TimerView.swift
//  Intent
//
//  Created by Livsy on 02.11.2022.
//

import SwiftUI

struct TimerView: View {
    
    @ObservedObject var viewModel: TimerViewModel = .init()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Timer")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom, 10)
            
            GeometryReader { proxy in
                
                VStack(spacing: 15) {
                    
                    
                    ZStack {
                        Circle()
                            .fill(.purple.opacity(0.3))
                            .padding(-40)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(.purple.opacity(0.3), lineWidth: 80)
                        
                        // MARK: Shadow
                        Circle()
                            .stroke(Color(Colors.Card.plum.rawValue), lineWidth: 5)
                            .blur(radius: 15)
                            .padding(-2)
                        
                        Circle()
                            .fill(Colors.Background.dark)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(Color(Colors.Card.plum.rawValue).opacity(0.7),lineWidth: 10)
                        
                        // MARK: Knob
                        GeometryReader { proxy in
                            let size = proxy.size
                            
                            Circle()
                                .fill(Color(Colors.Card.plum.rawValue))
                                .frame(width: 30, height: 30)
                                .overlay(content: {
                                    Circle()
                                        .fill(.white)
                                        .padding(5)
                                })
                                .frame(width: size.width, height: size.height, alignment: .center)
                            
                            // MARK: Since View is Rotated Thats Why Using X
                            
                                .offset(x: size.height / 2)
                                .rotationEffect(.init(degrees: viewModel.progress * 360))
                        }
                        
                        Text(viewModel.timerStringValue)
                            .font(.system(size: 45, weight: .light))
                            .rotationEffect(.init(degrees: 90))
                            .animation(.none, value: viewModel.progress)
                    }
                    .padding(60)
                    .frame(height: proxy.size.width)
                    .rotationEffect(.init(degrees: -90))
                    .animation(.easeInOut, value: viewModel.progress)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
                    Button {
                        if viewModel.isStarted {
                            viewModel.stopTimer()
                        } else {
                            viewModel.addNewTimer = true
                        }
                    } label: {
                        Image(systemName: !viewModel.isStarted ? "timer" : "stop.fill")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background {
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .fill(Colors.Background.dark)
                                    .blur(radius: 2)
                                
                                // MARK: Borders
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .stroke(
                                        .linearGradient(colors: [
                                            .white.opacity(0.6),
                                            .clear,
                                            .purple.opacity(0.2),
                                            .purple.opacity(0.5)
                                        ], startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 2
                                    )
                            }
                            .shadow(color: Color(Colors.Card.plum.rawValue), radius: 8, x: 0, y: 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .padding()
        .background {
            InteractiveBackgroundView()
                .padding(.top, 50)
                .ignoresSafeArea()
        }
        .overlay(content: {
            ZStack {
                Color.black
                    .opacity(viewModel.addNewTimer ? 0.25 : 0)
                    .onTapGesture {
                        viewModel.hour = 0
                        viewModel.minutes = 0
                        viewModel.seconds = 0
                        viewModel.addNewTimer = false
                    }
                
                NewTimerView()
                    .frame(maxHeight: .infinity,alignment: .bottom)
                    .offset(y: viewModel.addNewTimer ? 0 : 400)
            }
            .animation(.easeInOut, value: viewModel.addNewTimer)
        })
        .preferredColorScheme(.dark)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if viewModel.isStarted{
                viewModel.updateTimer()
            }
        }
        .alert("Done!", isPresented: $viewModel.isFinished) {
            Button("Start New",role: .cancel) {
                viewModel.stopTimer()
                viewModel.addNewTimer = true
            }
            Button("Close", role: .destructive) {
                viewModel.stopTimer()
            }
        }
    }
    
    // MARK: New Timer Bottom Sheet
    
    @ViewBuilder
    private func NewTimerView() -> some View {
        
        let isEnabledStatus = viewModel.seconds != 0 || viewModel.minutes != 0 || viewModel.hour != 0
        
        VStack(spacing: 15) {
            Text("Set timer")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.top, 10)
            
            HStack(spacing: 10) {
                
                Menu("\(viewModel.hour) hr") {
                    ContextMenuOptions(maxValue: 12, hint: "hr") { value in
                        viewModel.hour = value
                    }
                }
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(width: 95, height: 50, alignment: .center)
                .background{
                    Capsule()
                        .fill(.white.opacity(0.07))
                }
                
                Menu("\(viewModel.minutes) min") {
                    ContextMenuOptions(maxValue: 60, hint: "min") { value in
                        viewModel.minutes = value
                    }
                }
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(width: 95, height: 50, alignment: .center)
                .background{
                    Capsule()
                        .fill(.white.opacity(0.07))
                }
                
                Menu("\(viewModel.seconds) sec") {
                    ContextMenuOptions(maxValue: 60, hint: "sec") { value in
                        viewModel.seconds = value
                    }
                }
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(width: 95, height: 50, alignment: .center)
                .background{
                    Capsule()
                        .fill(.white.opacity(0.07))
                }
            }
            .padding(.top, 20)
            
            Button {
                viewModel.startTimer()
            } label: {
                Text("Start")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .opacity(isEnabledStatus ? 1 : 0.2)
                    .padding(.vertical)
                    .padding(.horizontal, 100)
                    .background {
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(
                                .linearGradient(colors: [
                                    .purple.opacity(0.25),
                                    .purple.opacity(0.09),
                                    .purple.opacity(0.25)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .blur(radius: 2)
                        
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(
                                .linearGradient(colors: [
                                    .purple.opacity(0.6),
                                    .purple.opacity(0.2),
                                    .purple.opacity(0.5)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                        
                    }
            }
            .disabled(!isEnabledStatus)
            .opacity(!isEnabledStatus ? 0.5 : 1)
            .padding(.top)
            .glow(color: isEnabledStatus ? .purple : .clear, radius: isEnabledStatus ? 5 : 0)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Colors.Background.dark)
                .ignoresSafeArea()
        }
    }
        
    @ViewBuilder
    private func ContextMenuOptions(
        maxValue: Int,
        hint: String,
        onClick: @escaping (Int)->()
    ) -> some View {
        
        ForEach(0...maxValue, id: \.self) { value in
            Button("\(value) \(hint)") {
                onClick(value)
            }
        }
    }
}

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
                    ForEach(0..<itemCount,id: \.self) { _ in
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
    
    private func itemScale(rect: CGRect,size: CGSize) -> CGFloat{
        let a = location.x - rect.midX
        let b = location.y - rect.midY
        
        let root = sqrt((a * a) + (b * b))
        let diagonalValue = sqrt((size.width * size.width) + (size.height * size.height))
        
        let scale = root / (diagonalValue / 2)
        let modifiedScale = location == .zero ? 1 : (1 - scale)
                
        return modifiedScale > 0 ? modifiedScale : 0.001
    }
}
