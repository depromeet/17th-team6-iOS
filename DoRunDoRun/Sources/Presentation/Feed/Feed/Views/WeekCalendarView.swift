//
//  WeekCalendarView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/11/25.
//

import SwiftUI

struct WeekCalendarView: View {
    let weekDates: [Date]
    let selectedDate: Date
    let weekCounts: [SelfieWeekCountResult]
    let onSelect: (Date) -> Void
    let onWeekChange: (Int) -> Void

    @GestureState private var dragOffset: CGFloat = 0
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TypographyText(text: monthWeekTitle, style: .t2_700)
                Spacer()
                HStack(spacing: 0) {
                    Button(action: { onWeekChange(-1) }) {
                        Image(.arrowLeft, size: .small)
                    }
                    .frame(width: 26, height: 26)

                    Button(action: { onWeekChange(1) }) {
                        Image(.arrowRight, size: .small)
                    }
                    .frame(width: 26, height: 26)
                }
            }

            HStack(spacing: 0) {
                ForEach(weekDates.indices, id: \.self) { index in
                    let date = weekDates[index]
                    let dateString = DateFormatterManager.shared.formatAPIDateText(from: date)
                    let count = weekCounts.first(where: { $0.date == dateString })?.selfieCount ?? 0

                    VStack(spacing: 8) {
                        TypographyText(text: weekdaySymbol(for: date), style: .b2_500, color: .gray500)
                        Button {
                            onSelect(date)
                        } label: {
                            VStack(spacing: 4) {
                                TypographyText(
                                    text: dayLabel(for: date),
                                    style: .b2_500,
                                    color: textColor(for: date)
                                )
                                .frame(width: 40, height: 28)
                                .background(circleBackground(for: date))
                                .clipShape(Capsule())

                                TypographyText(
                                    text: count > 0 ? "+\(count)" : "0",
                                    style: .c1_500,
                                    color: count > 0 ? .blue600 : .gray400
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    if index != weekDates.count - 1 {
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .updating($dragOffset, body: { value, state, _ in
                    state = value.translation.width
                })
                .onEnded { value in
                    if value.translation.width < -50 {
                        onWeekChange(1)
                    } else if value.translation.width > 50 {
                        onWeekChange(-1)
                    }
                }
        )
    }
}

// MARK: - Helpers
private extension WeekCalendarView {
    func weekdaySymbol(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let koreanWeekdays = ["일", "월", "화", "수", "목", "금", "토"]
        return koreanWeekdays[weekday - 1]
    }

    /// 오늘이면 "오늘", 아니면 일(day) 숫자 반환
    func dayLabel(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "오늘"
        } else {
            return "\(calendar.component(.day, from: date))"
        }
    }

    func textColor(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            return .gray0
        } else if calendar.isDateInToday(date) {
            return .blue600
        } else {
            return .gray900
        }
    }

    func circleBackground(for date: Date) -> Color {
        calendar.isDate(date, inSameDayAs: selectedDate) ? .blue600 : .gray0
    }

    var monthWeekTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        let month = formatter.string(from: selectedDate)
        let weekOfMonth = calendar.component(.weekOfMonth, from: selectedDate)
        return "\(month) \(weekOfMonth)주차"
    }
}
