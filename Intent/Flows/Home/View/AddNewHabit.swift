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
    
    /// Environment Values
    @Environment(\.self) var env
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.pink, Colors.Card.plum.color, Colors.Card.blueRose.color]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .ignoresSafeArea()
                
                ScrollViewReader { value in
                    VStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 15) {
                                TextFieldsStack()
                                    .id(0)
                                
                                Divider()
                                
                                // MARK: Habit Color Picker
                                
                                AddNewHabit.ColorPickerView(checkedColor: viewModel.habitColor) { color in
                                    isFocused = false
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
                                                        .fill(index != -1 ? Color(viewModel.habitColor) : Colors.Background.light.opacity(0.5))
                                                }
                                                .onTapGesture {
                                                    isFocused = false
                                                    UIImpactFeedbackGenerator(style: .medium)
                                                        .impactOccurred()
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
                                    .padding(.top, 15)
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
                        .scrollDismissesKeyboard(.interactively)
                        .onChange(of: viewModel.remainderDates) { _ in
                            withAnimation {
                                value.scrollTo(1)
                            }
                        }
                        .onChange(of: viewModel.isRemainderOn) { _ in
                            withAnimation {
                                viewModel.isRemainderOn ? value.scrollTo(1) : value.scrollTo(0)
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
                .navigationTitle(viewModel.editHabit != nil ? "Edit schedule" : "New schedule")
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
                            viewModel.isShowDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                        .opacity(viewModel.editHabit == nil ? 0 : 1)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            Task {
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
        }
        .overlay {
            if viewModel.showTimePicker {
                DatePickerView(forIndex: viewModel.timePickerIndex)
                    .onTapGesture {
                        isFocused = false
                    }
            } else if viewModel.isLoading {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                    
                    LoadingIndicatorView(showPopup: $viewModel.isLoading)
                }
            }
        }
        .alert("I can only schedule 64 notifications. Please edit this template or the previous ones", isPresented: $viewModel.isFull) {
            Button("OK", role: .cancel) { }
        }
        .alert("Are you sure?", isPresented: $viewModel.isShowDeleteAlert) {
            Button("No", role: .cancel) {}
            Button("Yes", role: .destructive) {
                if viewModel.deleteHabit(context: env.managedObjectContext) {
                    env.dismiss()
                }
            }
        }
        .onAppear {
            viewModel.isLoading = false
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
                .glow(color: isOnColor, radius: viewModel.isRemainderOn ? 4 : 0)
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
                let uiColor = UIColor(named: color) ?? .white
                let isChecked = color == checkedColor
                let checkedColor = isChecked ? Color(uiColor: uiColor) : .white
                let sideSize: CGFloat = isChecked ? 30 : 24
                
                Circle()
                    .fill(Color(color).opacity(isChecked ? 1 : 0.7))
                    .frame(width: sideSize, height: sideSize)
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
                        
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(
                                .linearGradient(colors: [
                                    .white.opacity(0.6),
                                    .clear,
                                    checkedColor.opacity(0.2),
                                    checkedColor.opacity(0.5),
                                    checkedColor.opacity(0.8)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 5
                            )
                            .glow(color: isChecked ? Color(color) : .clear, radius: .zero)
                    }
                    .overlay(content: {
                        if isChecked {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    })
                    .onTapGesture {
                        withAnimation {
                            colorCompletion?(color)
                            UIImpactFeedbackGenerator(style: .medium)
                                .impactOccurred()
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
                .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            
            TextField("Remainder text", text: $viewModel.remainderText)
                .focused($isFocused)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            
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
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.easeInOut) {
                            isFocused = false
                            guard let _ = viewModel.remainderDates[safe: forIndex] else { return }
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
                    UIImpactFeedbackGenerator(style: .medium)
                        .impactOccurred()
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
            
            if let _ = viewModel.remainderDates[safe: forIndex] {
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
    }
    
    @ViewBuilder
    private func AddTimeButton() -> some View {
        let isAvailable = viewModel.isRemainderOn && viewModel.notificationAccess && (viewModel.remainderDates.count * viewModel.weekDays.count) < 64
        
        Button {
            withAnimation(.easeInOut) {
                isFocused = false
                viewModel.remainderDates.append(Date())
                UIImpactFeedbackGenerator(style: .medium)
                    .impactOccurred()
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
        .frame(height: isAvailable ? nil : 0)
        .opacity(isAvailable ? 1 : 0)
    }
    
}

struct AddNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddNewHabit(viewModel: HabitViewModel())
            .preferredColorScheme(.dark)
    }
}

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
