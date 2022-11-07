//
//  Home.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI

struct Home: View {
    
    @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)], animation: .easeInOut) var habits: FetchedResults<Habit>
    @StateObject var viewModel: HabitViewModel = .init()
    @State var router: HomeScreenRouter?
    @State var dragOffset: CGSize = .zero
    @State var startAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: .zero) {
            Text("Intent")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button {
                        viewModel.isShowTimer.toggle()
                        UIImpactFeedbackGenerator(style: .medium)
                            .impactOccurred()
                    } label: {
                        Image(systemName: "timer")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom, 10)
                .sheet(isPresented: $viewModel.isShowTimer) {
                } content: {
                    router?.timerScreen()
                }
                .overlay(alignment: .trailing) {
                    Button {
                        viewModel.createTemplate.toggle()
                        UIImpactFeedbackGenerator(style: .medium)
                            .impactOccurred()
                    } label: {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom, 10)
                .fullScreenCover(isPresented: $viewModel.createTemplate) {
                    viewModel.reset()
                } content: {
                    router?.createTemplateScreen()
                }
            
            VStack {
                ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) {
                        ForEach(habits) {
                            HabitCardView(habit: $0)
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal, 2)
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium)
                        .impactOccurred()
                    viewModel.addNewHabit.toggle()
                } label: {
                    Label {
                        Text("New")
                    } icon: {
                        Image(systemName: "plus.circle")
                    }
                    .font(.callout.bold())
                    .foregroundColor(.primary)
                }
                .padding(.top, 15)
                .frame(maxWidth: .infinity, maxHeight: 20, alignment: .center)
            }
            
        }
        .frame(maxHeight: .infinity,alignment: .top)
        .padding()
        .onAppear {
            startAnimation = true
        }
        .fullScreenCover(isPresented: $viewModel.addNewHabit) {
            viewModel.reset()
        } content: {
            router?.addHabitScreen(viewModel: viewModel)
        }
        .background {
            ZStack {
                ClubbedView()
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: Habit Card View
    
    @ViewBuilder
    private func HabitCardView(habit: Habit) -> some View {
        Button {
            viewModel.editHabit = habit
            viewModel.restoreEditData()
            viewModel.addNewHabit.toggle()
        } label: {
            VStack(spacing: 6) {
                HStack{
                    Text(habit.title ?? "")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Image(systemName: "bell.badge.fill")
                        .font(.callout)
                        .foregroundColor(Color(habit.color ?? Colors.Card.raspberrySunset.rawValue))
                        .scaleEffect(0.9)
                        .opacity(habit.isRemainderOn ? 1 : 0)
                    
                    Spacer()
                    
                    let count = (habit.weekDays?.count ?? 0)
                    let timesText = count == 1 ? "time" : "times"
                    Text(count == 7 ? "Everyday" : "\(count) \(timesText) a week")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
       
                let calendar = Calendar.current
                let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
                let symbols = calendar.shortWeekdaySymbols
                let startDate = currentWeek?.start ?? Date()
                let activeWeekDays = habit.weekDays ?? []
                let activePlot: [(weekDay: String, date: Date)] = symbols.indices.compactMap { index -> (String, Date) in
                    let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)
                    return (symbols[index], currentDate ?? Date())
                }
                
                HStack(spacing: .zero) {
                    ForEach(activePlot.indices, id: \.self) { index in
                        let item = activePlot[index]
                        
                        VStack(spacing: 6) {
                            
                            Text(item.weekDay.capitalized)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            let status = activeWeekDays.contains { day in
                                return day == item.weekDay
                            }
                            
                            Text(viewModel.dateString(from: item.date))
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .padding(8)
                                .foregroundColor(status ? .white : .primary)
                                .background {
                                    Circle()
                                        .fill(Color(habit.color ?? Colors.Card.raspberrySunset.rawValue))
                                        .opacity(status ? 1 : 0)
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 15)
            }
            .padding(.vertical)
            .padding(.horizontal, 6)
            .background {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(
                        .linearGradient(colors: [
                            .white.opacity(0.25),
                            .white.opacity(0.05),
                            .clear
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .blur(radius: 2)
                
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
        }
        .buttonStyle(ScaledButtonStyle())
    }
    
    @ViewBuilder
    private func ClubbedView()->some View{
        Rectangle()
            .fill(.linearGradient(colors: [Color("Gradient1"),Color("Gradient2")], startPoint: .top, endPoint: .bottom))
            .mask({
                TimelineView(.animation(minimumInterval: 3.6, paused: false)) { _ in
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.5,color: .white))
                        context.addFilter(.blur(radius: 30))
                        context.drawLayer { ctx in
                            for index in 1...15{
                                if let resolvedView = context.resolveSymbol(id: index){
                                    ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                }
                            }
                        }
                    } symbols: {
                        ForEach(1...15,id: \.self){index in
                            let offset = (startAnimation ? CGSize(width: .random(in: -180...180), height: .random(in: -240...240)) : .zero)
                            ClubbedRoundedRectangle(offset: offset)
                                .tag(index)
                        }
                    }
                }
            })
            .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func ClubbedRoundedRectangle(offset: CGSize)->some View{
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.white)
            .frame(width: 120, height: 120)
            .offset(offset)
            .animation(.easeInOut(duration: 4), value: offset)
    }
        
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
