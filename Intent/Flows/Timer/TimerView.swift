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
                            .stroke(Colors.Card.plum.color, lineWidth: 5)
                            .blur(radius: 15)
                            .padding(-2)
                        
                        Circle()
                            .fill(Colors.Background.dark)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(Colors.Card.plum.color.opacity(0.7),lineWidth: 10)
                        
                        // MARK: Knob
                        GeometryReader { proxy in
                            let size = proxy.size
                            
                            Circle()
                                .fill(Colors.Card.plum.color)
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
                            .shadow(color: Colors.Card.plum.color, radius: 8, x: 0, y: 0)
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
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button {
                        viewModel.hour = 0
                        viewModel.minutes = 0
                        viewModel.seconds = 0
                        viewModel.addNewTimer = false
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 10)
            
            HStack(alignment: .center, spacing: 60) {
                
                Menu("\(viewModel.hour) hr") {
                    ContextMenuOptions(maxValue: 12, hint: "hr") { value in
                        viewModel.hour = value
                    }
                }
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.5))
                
                Menu("\(viewModel.minutes) min") {
                    ContextMenuOptions(maxValue: 60, hint: "min") { value in
                        viewModel.minutes = value
                    }
                }
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.5))
                
                Menu("\(viewModel.seconds) sec") {
                    ContextMenuOptions(maxValue: 60, hint: "sec") { value in
                        viewModel.seconds = value
                    }
                }
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.5))
            }
            .padding(.top, 20)
            
            Button {
                Task {
                    await viewModel.startTimer()
                }
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
        .alert("I can only schedule 64 notifications. Now there are 64 of them. Therefore, the timer will not send notifications", isPresented: $viewModel.isShowWarning) {
            Button("OK", role: .cancel) { }
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
