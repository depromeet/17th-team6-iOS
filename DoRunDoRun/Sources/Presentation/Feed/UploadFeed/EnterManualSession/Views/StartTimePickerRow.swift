//
//  StartTimePickerRow.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 2/10/26.
//

import SwiftUI

struct StartTimePickerRow: View {
    let title: String
    var required: Bool = false
    var placeholder: String
    @Binding var selectedDate: Date?

    @State private var pickerDate: Date = Date()
    @State private var isPresented: Bool = false

    // MARK: - Display Text

    private var displayText: String {
        guard let date = selectedDate else { return "" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a hh:mm"
        return formatter.string(from: date)
    }

    // MARK: - Body

    var body: some View {
        InputRow(title: title, required: required) {
            Button {
                isPresented = true
            } label: {
                HStack {
                    if selectedDate != nil {
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

                    Image(.arrowDown, size: .small)
                }
            }
        }
        .onAppear {
            if let selectedDate {
                pickerDate = selectedDate
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "",
                        selection: $pickerDate,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .padding(.top, 20)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // 취소 버튼
                    ToolbarItem(placement: .cancellationAction) {
                        Button("취소") {
                            isPresented = false
                        }
                    }
                    // 완료 버튼
                    ToolbarItem(placement: .confirmationAction) {
                        Button("완료") {
                            selectedDate = pickerDate
                            isPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }
}
