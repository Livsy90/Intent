//
//  Home.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI

protocol HomeScreenRouter: AnyObject {
    func addHabitScreen(viewModel: HabitViewModel) -> AddNewHabit
}

struct Home: View {
    
    @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)], animation: .easeInOut) var habits: FetchedResults<Habit>
    @StateObject var habitModel: HabitViewModel = .init()
    @State var router: HomeScreenRouter?
    
    var body: some View {
        VStack(spacing: .zero) {
            Text("Habits")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom,10)
            
            VStack {
                ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) {
                        ForEach(habits) {
                            HabitCardView(habit: $0)
                        }
                        .padding(.vertical)
                    }
                }
                
                Button {
                    habitModel.addNewHabit.toggle()
                } label: {
                    Label {
                        Text("New habit")
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
        .sheet(isPresented: $habitModel.addNewHabit) {
            
            // MARK: Erasing All Existing Content
            
            habitModel.reset()
        } content: {
            router?.addHabitScreen(viewModel: habitModel)
        }
    }
    
    // MARK: Habit Card View
    
    @ViewBuilder
    func HabitCardView(habit: Habit) -> some View{
        VStack(spacing: 6) {
            HStack{
                Text(habit.title ?? "")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Image(systemName: "bell.badge.fill")
                    .font(.callout)
                    .foregroundColor(Color(habit.color ?? Colors.Card.raspberrySunset.rawValue))
                    .scaleEffect(0.9)
                    .opacity(habit.isRemainderOn ? 1 : 0)
                
                Spacer()
                
                let count = (habit.weekDays?.count ?? 0)
                Text(count == 7 ? "Everyday" : "\(count) times a week")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            
            // MARK: Displaying Current Week and Marking Active Dates of Habit
            
            let calendar = Calendar.current
            let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
            let symbols = calendar.weekdaySymbols
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
                        
                        Text(item.weekDay.prefix(3).capitalized)
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
        .background{
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("TFBG").opacity(0.5))
        }
        .onTapGesture {
            // MARK: Editing Habit
            habitModel.editHabit = habit
            habitModel.restoreEditData()
            habitModel.addNewHabit.toggle()
        }
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
