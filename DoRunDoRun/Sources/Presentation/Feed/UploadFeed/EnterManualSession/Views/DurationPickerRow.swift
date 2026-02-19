//
//  DurationPickerRow.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/19/26.
//

import SwiftUI

struct DurationPickerRow: View {
    let title: String
    var required: Bool = false
    var placeholder: String
    @Binding var selectedDuration: DateComponents?

    @State private var hour: Int = 0
    @State private var minute: Int = 0
    @State private var second: Int = 0
    @State private var isPresented = false

    private var displayText: String {
        guard let selectedDuration else { return "" }

        let hh = selectedDuration.hour ?? 0
        let mm = selectedDuration.minute ?? 0
        let ss = selectedDuration.second ?? 0

        return String(format: "%02d:%02d:%02d", hh, mm, ss)
    }

    var body: some View {

        InputRow(title: title, required: required) {
            Button {
                isPresented = true
            } label: {
                HStack {
                    if selectedDuration != nil {
                        TypographyText(
                            text: displayText,
                            style: .b1_500,
                            color: .gray900
                        )
                    } else {
                        TypographyText(
                            text: placeholder,
                            style: .b1_500,
                            color: .gray300
                        )
                    }

                    Spacer()

                    TypographyText(text: "시간", style: .b1_500)
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                VStack(spacing: 0) {

                    HStack(spacing: 0) {

                        Picker("Hour", selection: $hour) {
                            ForEach(0..<24, id: \.self) {
                                Text("\($0)시간").tag($0)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Minute", selection: $minute) {
                            ForEach(0..<60, id: \.self) {
                                Text("\($0)분").tag($0)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Second", selection: $second) {
                            ForEach(0..<60, id: \.self) {
                                Text("\($0)초").tag($0)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(height: 200)

                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("취소") {
                            isPresented = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("완료") {
                            selectedDuration = DateComponents(
                                hour: hour,
                                minute: minute,
                                second: second
                            )
                            isPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if let selectedDuration {
                hour = selectedDuration.hour ?? 0
                minute = selectedDuration.minute ?? 0
                second = selectedDuration.second ?? 0
            }
        }
    }
}
