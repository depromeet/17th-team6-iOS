//
//  PacePickerRow.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/19/26.
//

import SwiftUI

struct PacePickerRow: View {
    let title: String
    var placeholder: String
    @Binding var minute: Int?
    @Binding var second: Int?

    @State private var selectedMinute: Int = 5
    @State private var selectedSecond: Int = 0
    @State private var isPresented = false

    private var displayText: String {
        guard let minute, let second else { return "" }
        return "\(minute)'\(String(format: "%02d", second))\""
    }

    var body: some View {

        InputRow(title: title) {
            Button {
                isPresented = true
            } label: {
                HStack {
                    if minute != nil && second != nil {
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
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                VStack {

                    HStack(spacing: 0) {

                        // 분
                        Picker("Minute", selection: $selectedMinute) {
                            ForEach(0...59, id: \.self) {
                                Text("\($0)분").tag($0)
                            }
                        }
                        .pickerStyle(.wheel)

                        // 초
                        Picker("Second", selection: $selectedSecond) {
                            ForEach(0...59, id: \.self) {
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
                            minute = selectedMinute
                            second = selectedSecond
                            isPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if let minute {
                selectedMinute = minute
            }
            if let second {
                selectedSecond = second
            }
        }
    }
}
