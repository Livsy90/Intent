//
//  AddNewHabit.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI

struct AddNewHabit: View {
    
    @ObservedObject var habitModel: HabitViewModel
    
    /// Environment Values
    @Environment(\.self) var env
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Spacer()
                TextFieldsStack()
                Divider()
                
                // MARK: Habit Color Picker
                
                AddNewHabit.ColorPickerView(checkedColor: habitModel.habitColor) { color in
                    habitModel.habitColor = color
                }
                .padding(.vertical)
                
                Divider()
                
                // MARK: Frequency Selection
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Frequency")
                        .font(.callout.bold())
                    let weekDays = Calendar.current.shortWeekdaySymbols
                    HStack(spacing: 10) {
                        ForEach(weekDays, id: \.self) { day in
                            let index = habitModel.weekDays.firstIndex { value in
                                return value.caseInsensitiveCompare(day) == .orderedSame
                            } ?? -1
                            
                            Text(day.capitalized)
                                .font(.system(size: 13))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(index != -1 ? .white : .primary)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(index != -1 ? Color(habitModel.habitColor) : Colors.Background.light)
                                }
                                .onTapGesture {
                                    withAnimation {
                                        if index != -1{
                                            habitModel.weekDays.remove(at: index)
                                        } else {
                                            habitModel.weekDays.append(day)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top,15)
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                // Hiding if Notification access is rejected
                RemainderSwitchView()
                
                ScrollViewReader { value in
                    ScrollView(habitModel.remainderDates.count > 1 ? .vertical : .init(), showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible())], spacing: .zero) {
                            ForEach(habitModel.remainderDates.indices, id: \.self) { index in
                                RemainderTimeView(forIndex: index)
                                    .transition(.move(edge: .bottom))
                            }
                            .padding(.vertical)
                        }
                    }
                    .onChange(of: habitModel.remainderDates.count) { _ in
                        withAnimation {
                            value.scrollTo(habitModel.remainderDates.count - 1)
                        }
                    }
                }
                
                AddTimeButton()
                
            }
            .animation(.easeInOut, value: habitModel.isRemainderOn)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(habitModel.editHabit != nil ? "Edit Habit" : "Add Habit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.primary)
                }
                
                // MARK: Delete Button
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if habitModel.deleteHabit(context: env.managedObjectContext) {
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .opacity(habitModel.editHabit == nil ? 0 : 1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        Task {
                            if await habitModel.addHabbit(context: env.managedObjectContext) {
                                env.dismiss()
                            }
                        }
                    }
                    .tint(.primary)
                    .disabled(!habitModel.doneStatus())
                    .opacity(habitModel.doneStatus() ? 1 : 0.6)
                }
            }
        }
        .overlay {
            if habitModel.showTimePicker {
                DatePickerView(forIndex: habitModel.timePickerIndex)
            }
        }
    }
    
    // MARK: - Remainder swtich
    
    @ViewBuilder
    private func RemainderSwitchView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Remainder")
                    .fontWeight(.semibold)
                
                Text("Just notification")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            
            Toggle(isOn: $habitModel.isRemainderOn) {}
                .labelsHidden()
        }
        .opacity(habitModel.notificationAccess ? 1 : 0)
    }
    
    // MARK: - Color Picker
    
    @ViewBuilder
    static func ColorPickerView(
        checkedColor: String,
        _ colorCompletion: ((String) -> Void)?
    ) -> some View {
        
        HStack(spacing: 0) {
            ForEach(1...7, id: \.self) { index in
                let color = Colors.Card.color(for: index)
                Circle()
                    .fill(Color(color))
                    .frame(width: 30, height: 30)
                    .overlay(content: {
                        if color == checkedColor {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    })
                    .onTapGesture {
                        withAnimation {
                            colorCompletion?(color)
                        }
                    }
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private  func TextFieldsStack() -> some View {
        VStack(spacing: 15) {
            Spacer()
            Text("Enter reminder details")
            Spacer()
            TextField("Title", text: $habitModel.title)
                .ignoresSafeArea(.keyboard)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            
            TextField("Remainder text", text: $habitModel.remainderText)
                .ignoresSafeArea(.keyboard)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))

        }
    }
    
    
    // MARK: - Time
    
    @ViewBuilder
    private func RemainderTimeView(forIndex: Int) -> some View {
        HStack(spacing: 12) {
            Label {
                Text("Remainder time")
            } icon: {
               
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            
            Label {
                Text(habitModel.remainderDates[forIndex].formatted(date: .omitted, time: .shortened))
            } icon: {
                Image(systemName: "clock")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .onTapGesture {
                withAnimation {
                    habitModel.showTimePicker.toggle()
                    habitModel.timePickerIndex = forIndex
                }
            }
            
            if forIndex > .zero {
                Button {
                    habitModel.remainderDates.remove(at: forIndex)
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(height: habitModel.isRemainderOn ? nil : 0)
        .opacity(habitModel.isRemainderOn ? 1 : 0)
        .opacity(habitModel.notificationAccess ? 1 : 0)
    }
    
    // MARK: - Date Picker
    
    @ViewBuilder
    private func DatePickerView(forIndex: Int) -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        habitModel.showTimePicker.toggle()
                    }
                }
            
            DatePicker.init("", selection: $habitModel.remainderDates[forIndex], displayedComponents: [.hourAndMinute])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Colors.Background.dark)
                }
                .padding()
        }
    }
    
    @ViewBuilder
    private func AddTimeButton() -> some View {
        Button {
            withAnimation(.easeInOut) {
                habitModel.remainderDates.append(Date())
            }
        } label: {
            Label {
                Text("Add time")
            } icon: {
                Image(systemName: "plus.circle")
            }
            .font(.callout.bold())
            .foregroundColor(.primary)
        }
        .padding(.top, 15)
        .frame(height: habitModel.isRemainderOn && habitModel.remainderDates.count <= 96 ? nil : 0)
        .opacity(habitModel.isRemainderOn ? 1 : 0)
        .opacity(habitModel.notificationAccess ? 1 : 0)
        .opacity(habitModel.remainderDates.count <= 96 ? 1 : 0)
    }
    
}

struct AddNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddNewHabit(habitModel: HabitViewModel())
            .preferredColorScheme(.dark)
    }
}
