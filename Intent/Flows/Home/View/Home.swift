//
//  Home.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI

protocol HomeScreenRouter: AnyObject {
    func addHabitScreen(viewModel: HabitViewModel) -> AddNewHabit
    func createTemplateScreen() -> CreateTemplateView
}

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
                .overlay(alignment: .trailing) {
                    Button {
                        viewModel.createTemplate.toggle()
                    } label: {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom,10)
                .sheet(isPresented: $viewModel.createTemplate) {
                    viewModel.isLoading = false
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
        .sheet(isPresented: $viewModel.addNewHabit) {
            
            // MARK: Erasing All Existing Content
            viewModel.isLoading = false
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
    func HabitCardView(habit: Habit) -> some View{
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
            
            // MARK: Displaying Current Week and Marking Active Dates of Habit
            
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
                        
                        Text(getDate(date: item.date))
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
        .onTapGesture {
            // MARK: Editing Habit
            viewModel.editHabit = habit
            viewModel.restoreEditData()
            viewModel.addNewHabit.toggle()
        }
    }
    
    // MARK: Clubbed One
    // Like Blob Background Animation
    @ViewBuilder
    private func ClubbedView()->some View{
        Rectangle()
            .fill(.linearGradient(colors: [Color("Gradient1"),Color("Gradient2")], startPoint: .top, endPoint: .bottom))
            .mask({
                // It's Quite the Same With the Addition of TimelineView
                // MARK: Timing Is Your Wish for how Long The Animation needs to be Changed
                TimelineView(.animation(minimumInterval: 3.6, paused: false)) { _ in
                    Canvas { context, size in
                        // MARK: Adding Filters
                        // Change here If you need Custom Color
                        context.addFilter(.alphaThreshold(min: 0.5,color: .white))
                        // MARK: This blur Radius determines the amount of elasticity between two elements
                        context.addFilter(.blur(radius: 30))
                        
                        // MARK: Drawing Layer
                        context.drawLayer { ctx in
                            // MARK: Placing Symbols
                            for index in 1...15{
                                if let resolvedView = context.resolveSymbol(id: index){
                                    ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                }
                            }
                        }
                    } symbols: {
                        // MARK: Count is your wish
                        ForEach(1...15,id: \.self){index in
                            // MARK: Generating Custom Offset For Each Time
                            // Thus It will be at random places and clubbed with each other
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
            // MARK: Adding Animation[Less Than TimelineView Refresh Rate]
            .animation(.easeInOut(duration: 4), value: offset)
    }
    
    /// Formatting Date
    private func getDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        return formatter.string(from: date)
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
