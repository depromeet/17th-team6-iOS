import SwiftUI

/// 토스트의 표시 위치
enum ToastPosition {
    case top
    case bottom
}

extension View {
    /// 원하는 ToastView를 자유롭게 주입할 수 있는 헬퍼 메서드
    ///
    /// ```
    /// .toast(isPresented: $showToast, position: .top) {
    ///     NoticeToastView(message: "‘수연’님이 응원을 보냈어요!", imageName: "graphic_congrats")
    /// }
    /// ```
    func toast<ToastContent: View>(
        isPresented: Binding<Bool>,
        position: ToastPosition = .top,
        duration: TimeInterval = 3,
        @ViewBuilder content: @escaping () -> ToastContent
    ) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue {
                VStack {
                    if position == .top {
                        content()
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .padding(.top, 40)
                        Spacer()
                    } else {
                        Spacer()
                        content()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 40)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isPresented.wrappedValue)
                .onAppear {
                    // 자동 사라짐 처리
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isPresented.wrappedValue = false
                        }
                    }
                }
            }
        }
    }
}
