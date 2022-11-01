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
                                HStack(spacing: 6) {
                                    ForEach(weekDays, id: \.self) { day in
                                        let index = viewModel.weekDays.firstIndex { value in
                                            return value.caseInsensitiveCompare(day) == .orderedSame
                                        } ?? -1
                                        
                                        Text(day.capitalized)
                                            .font(.system(size: 13))
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
            
            let isOnColor = viewModel.isRemainderOn ? Color(.green) : Color(.white)

            
            Toggle(isOn: $viewModel.isRemainderOn) {}
                .labelsHidden()
                .background {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(
                            .linearGradient(colors: [
                                isOnColor.opacity(0.6),
                                isOnColor.opacity(0.4),
                                .clear,
                                .white.opacity(0.2),
                                .white.opacity(0.5)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 4
                        )
                }
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
                let uiColor = UIColor(named: color) ?? .clear
                
                Circle()
                    .fill(Color(color))
                    .frame(width: 30, height: 30)
                    .background {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(
                                .linearGradient(colors: [
                                    .white.opacity(0.6),
                                    .clear,
                                    .init(uiColor: uiColor).opacity(0.2),
                                    .init(uiColor: uiColor).opacity(0.5),
                                    .init(uiColor: uiColor).opacity(0.8)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 5
                            )
                    }
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
                        withAnimation(.easeInOut) {
                            isFocused = false
                            viewModel.remainderDates.remove(at: forIndex)
                        }
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
            .background {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(
                        .linearGradient(colors: [
                            .white.opacity(0.25),
                            .white.opacity(0.05),
                            .clear
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .blur(radius: 5)
                
                // MARK: Borders
                let color: Color = forIndex > .zero ? .red : .white
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(
                        .linearGradient(colors: [
                            .white.opacity(0.6),
                            .clear,
                            forIndex > .zero ? .purple.opacity(0.2) : color.opacity(0.2),
                            color.opacity(0.5)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 2
                    )
                
            }
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

// MARK: Custom Blur View
// With The Help of UiVisualEffect View
struct CustomBlurView: UIViewRepresentable{
    var effect: UIBlurEffect.Style
    var onChange: (UIVisualEffectView)->()
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            onChange(uiView)
        }
    }
}
