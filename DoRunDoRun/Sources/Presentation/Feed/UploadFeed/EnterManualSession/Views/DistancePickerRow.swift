//
//  DistancePickerRow.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/19/26.
//

import SwiftUI

struct DistancePickerRow: View {
    let title: String
    var required: Bool = false
    var placeholder: String
    @Binding var whole: Int?
    @Binding var decimal: Int?

    @State private var selectedWhole: Int = 1
    @State private var selectedDecimal: Int = 0
    @State private var isPresented = false

    private var displayText: String {
        guard let whole, let decimal else { return "" }
        return String(format: "%d.%02d", whole, decimal)
    }

    var body: some View {

        InputRow(title: title, required: required) {
            Button {
                isPresented = true
            } label: {
                HStack {
                    if whole != nil && decimal != nil {
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

                    TypographyText(text: "km", style: .b1_500)
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                VStack {

                    HStack(spacing: 0) {

                        // 정수 부분 (1~99)
                        Picker("Whole", selection: $selectedWhole) {
                            ForEach(1...99, id: \.self) {
                                Text("\($0)").tag($0)
                            }
                        }
                        .pickerStyle(.wheel)

                        Text(".")
                            .font(.title2)
                            .padding(.horizontal, 4)

                        // 소수 부분 (00~99)
                        Picker("Decimal", selection: $selectedDecimal) {
                            ForEach(0...99, id: \.self) {
                                Text(String(format: "%02d", $0)).tag($0)
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
                            whole = selectedWhole
                            decimal = selectedDecimal
                            isPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if let whole {
                selectedWhole = whole
            }
            if let decimal {
                selectedDecimal = decimal
            }
        }
    }
}
