//
//  CreateTemplateView.swift
//  Intent
//
//  Created by Livsy on 30.10.2022.
//

import SwiftUI

struct CreateTemplateView: View {
    
    @ObservedObject var viewModel: CreateTemplateViewModel
    @FocusState var isFocused: Bool
    
    /// Environment Values
    @Environment(\.self) var env
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { value in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        TextField("Title", text: $viewModel.title)
                            .focused($isFocused)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        
                        TextField("Remainder text", text: $viewModel.remainderText)
                            .focused($isFocused)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 12)
                            .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        
                        Divider()
                        
                        // MARK: Habit Color Picker
                        
                        AddNewHabit.ColorPickerView(checkedColor: viewModel.habitColor) { color in
                            viewModel.habitColor = color
                        }
                        .padding(.vertical)
                        .onTapGesture {
                            isFocused = false
                        }
                        
                        Divider()
                        
                        RemainderTimeView()
                            .onTapGesture {
                                isFocused = false
                            }
                        
                        Divider()
                        
                        Text("Repeat every")
                        
                        Picker("Repeat every", selection: $viewModel.step) {
                            ForEach(Step.allCases, id: \.self) {
                                Text($0.rawValue.lowercased())
                            }
                        }
                        .accentColor(Color(.label))
                        .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .onTapGesture {
                            isFocused = false
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Create with template")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                env.dismiss()
                            } label: {
                                Image(systemName: "xmark.circle")
                            }
                            .tint(.primary)
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
        }
        .overlay {
            if viewModel.showStartTimePicker || viewModel.showEndTimePicker {
                DatePickerView(isStart: viewModel.showStartTimePicker)
            } else if viewModel.isLoading {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        
                    ProgressView()
                }
            }
        }
        .onTapGesture {
            isFocused = false
        }
        .alert("We can only schedule 64 notifications. Please change start time / end time", isPresented: $viewModel.isFull) {
            Button("OK", role: .cancel) { }
        }
    }
    
    @ViewBuilder
    private func DatePickerView(isStart: Bool) -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isStart ? viewModel.showStartTimePicker.toggle() : viewModel.showEndTimePicker.toggle()
                        
                    }
                }
            
            DatePicker.init("", selection: isStart ? $viewModel.startDate : $viewModel.endDate, displayedComponents: [.hourAndMinute])
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
    
    // MARK: - Time
    
    @ViewBuilder
    private func RemainderTimeView() -> some View {
        VStack {
            HStack(spacing: 12) {
                Text("Start")
                    .frame(width: 60, height: 20)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                
                Label {
                    Text(viewModel.startDate.formatted(date: .omitted, time: .shortened))
                } icon: {
                    Image(systemName: "clock")
                }
                .frame(width: 130, height: 20)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            .onTapGesture {
                withAnimation {
                    viewModel.showStartTimePicker.toggle()
                }
            }
            
            HStack(spacing: 12) {
                Text("End")
                    .frame(width: 60, height: 20)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                Label {
                    Text(viewModel.endDate.formatted(date: .omitted, time: .shortened))
                } icon: {
                    Image(systemName: "clock")
                }
                .frame(width: 130, height: 20)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .background(Colors.Background.light, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            .onTapGesture {
                withAnimation {
                    viewModel.showEndTimePicker.toggle()
                }
            }
        }
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTemplateView(viewModel: .init())
    }
}
