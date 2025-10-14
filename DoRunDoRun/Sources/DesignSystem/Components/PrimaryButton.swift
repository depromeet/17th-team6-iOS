import SwiftUI

enum ButtonSize {
    case large
    case small
    
    var height: CGFloat {
        switch self {
        case .large: return 56
        case .small: return 44
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .large: return 12
        case .small: return 8
        }
    }
}

struct PrimaryButton: View {
    let title: String
    var size: ButtonSize = .large
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .typography(.b1_700, color: isDisabled ? .gray400 : .gray0)
                .frame(maxWidth: .infinity, minHeight: size.height)
                .background(isDisabled ? Color.gray50 : Color.blue600)
                .cornerRadius(size.cornerRadius)
        }
        .allowsHitTesting(!isDisabled)
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "오늘의 러닝 시작", size: .large) {
            print("큰 버튼 - 활성화")
        }
        
        PrimaryButton(title: "응원하기", size: .small) {
            print("작은 버튼 - 활성화")
        }
        .frame(width: 75)

        PrimaryButton(title: "응원완료", size: .small, isDisabled: true) {
            print("작은 버튼 - 비활성화")
        }
        .frame(width: 75)
    }
    .padding()
}
