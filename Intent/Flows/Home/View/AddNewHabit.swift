//
//  AddNewHabit.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI

struct AddNewHabit: View {
    
    @ObservedObject var viewModel: HabitViewModel
    @FocusState var isFocused: Bool
    @State var isLoading: Bool = false
    
    /// Environment Values
    @Environment(\.self) var env
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { value in
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 15) {
                            TextFieldsStack()
                            Divider()
                            
                            // MARK: Habit Color Picker
                            
                            AddNewHabit.ColorPickerView(checkedColor: viewModel.habitColor) { color in
                                viewModel.habitColor = color
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
                                        let index = viewModel.weekDays.firstIndex { value in
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
                                                    .fill(index != -1 ? Color(viewModel.habitColor) : Colors.Background.light)
                                            }
                                            .onTapGesture {
                                                withAnimation {
                                                    if index != -1{
                                                        viewModel.weekDays.remove(at: index)
                                                    } else {
                                                        viewModel.weekDays.append(day)
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
                                .padding()
                                .onTapGesture {
                                    isFocused = false
                                }
                            
                            TimeView()
                            
                            Color.clear
                                .frame(height: .zero)
                                .id(1)
                        }
                    }
                    .onChange(of: viewModel.remainderDates) { _ in
                        withAnimation {
                            value.scrollTo(1)
                        }
                    }
                    .onChange(of: viewModel.isRemainderOn) { _ in
                        withAnimation {
                            value.scrollTo(1)
                        }
                    }
                    AddTimeButton()
                        .onTapGesture {
                            isFocused = false
                        }
                }
            }
            .animation(.easeInOut, value: viewModel.isRemainderOn)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.editHabit != nil ? "Edit Habit" : "Add Habit")
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
                        if viewModel.deleteHabit(context: env.managedObjectContext) {
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .opacity(viewModel.editHabit == nil ? 0 : 1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        Task {
                            isLoading = true
                            if await viewModel.addHabbit(context: env.managedObjectContext) {
                                env.dismiss()
                            }
                        }
                    }
                    .tint(.primary)
                    .disabled(!viewModel.doneStatus())
                    .opacity(viewModel.doneStatus() ? 1 : 0.6)
                }
            }
        }
        .overlay {
            if viewModel.showTimePicker {
                DatePickerView(forIndex: viewModel.timePickerIndex)
                    .onTapGesture {
                        isFocused = false
                    }
            } else if isLoading {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        
                    ProgressView()
                }
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
            
            Toggle(isOn: $viewModel.isRemainderOn) {}
                .labelsHidden()
        }
        .opacity(viewModel.notificationAccess ? 1 : 0)
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
    private func TextFieldsStack() -> some View {
        VStack(spacing: 15) {
            TextField("Title", text: $viewModel.title)
                .focused($isFocused)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            
            TextField("Remainder text", text: $viewModel.remainderText)
                .focused($isFocused)
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
                Text(viewModel.remainderDates[forIndex].formatted(date: .omitted, time: .shortened))
                
                if forIndex > .zero {
                    Button {
                        viewModel.remainderDates.remove(at: forIndex)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(.leading)
                    }
                }
            } icon: {
                Image(systemName: "clock")
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .onTapGesture {
                withAnimation {
                    viewModel.showTimePicker.toggle()
                    viewModel.timePickerIndex = forIndex
                }
            }
        }
        .frame(height: viewModel.isRemainderOn ? nil : 0)
        .opacity(viewModel.isRemainderOn ? 1 : 0)
        .opacity(viewModel.notificationAccess ? 1 : 0)
    }
    
    @ViewBuilder
    private func TimeView() -> some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: .zero) {
            ForEach(viewModel.remainderDates.indices, id: \.self) { index in
                RemainderTimeView(forIndex: index)
                    .transition(.move(edge: .bottom))
                    .id(index)
            }
            .padding(.vertical)
        }
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
                        viewModel.showTimePicker.toggle()
                    }
                }
            
            DatePicker.init("", selection: $viewModel.remainderDates[forIndex], displayedComponents: [.hourAndMinute])
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
                isFocused = false
                viewModel.remainderDates.append(Date())
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
        .frame(height: viewModel.isRemainderOn && (viewModel.remainderDates.count * viewModel.weekDays.count) < 64 ? nil : 0)
        .opacity(viewModel.isRemainderOn ? 1 : 0)
        .opacity(viewModel.notificationAccess ? 1 : 0)
        .opacity((viewModel.remainderDates.count * viewModel.weekDays.count) < 64 ? 1 : 0)
    }
    
}

struct AddNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddNewHabit(viewModel: HabitViewModel())
            .preferredColorScheme(.dark)
    }
}
