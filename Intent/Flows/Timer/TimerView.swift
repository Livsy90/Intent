//
//  TimerView.swift
//  Intent
//
//  Created by Livsy on 02.11.2022.
//

import SwiftUI

struct TimerView: View {
    
    @ObservedObject var viewModel: TimverViewModel = .init()
    
    var body: some View {
        VStack{
            Text("Timer")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            GeometryReader { proxy in
                
                VStack(spacing: 15) {
                    
                    // MARK: Timer Ring
                    
                    ZStack{
                        Circle()
                            .fill(.white.opacity(0.03))
                            .padding(-40)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(.white.opacity(0.03), lineWidth: 80)
                        
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
                                Circle()
                                    .fill(Color(Colors.Card.plum.rawValue))
                            }
                            .shadow(color: Color(Colors.Card.plum.rawValue), radius: 8, x: 0, y: 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .padding()
        .background {
            Colors.Background.dark
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
        VStack(spacing: 15){
            Text("Add New Timer")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.top,10)
            
            HStack(spacing: 15){
                Text("\(viewModel.hour) hr")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 12, hint: "hr") { value in
                            viewModel.hour = value
                        }
                    }
                
                Text("\(viewModel.minutes) min")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 60, hint: "min") { value in
                            viewModel.minutes = value
                        }
                    }
                
                Text("\(viewModel.seconds) sec")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 60, hint: "sec") { value in
                            viewModel.seconds = value
                        }
                    }
            }
            .padding(.top, 20)
            
            Button {
                viewModel.startTimer()
            } label: {
                Text("Save")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .padding(.horizontal, 100)
                    .background{
                        Capsule()
                            .fill(Color(Colors.Card.plum.rawValue))
                    }
            }
            .disabled(viewModel.seconds == 0)
            .opacity(viewModel.seconds == 0 ? 0.5 : 1)
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Colors.Background.dark)
                .ignoresSafeArea()
        }
    }
    
    // MARK: Reusable Context Menu Options
    
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
