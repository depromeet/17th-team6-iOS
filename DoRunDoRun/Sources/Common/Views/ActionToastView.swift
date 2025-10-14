import SwiftUI

struct ActionToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .typography(.b2_500, color: .gray0)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.gray800)
            .cornerRadius(12)
    }
}

#Preview {
    VStack {
        Spacer()
        ActionToastView(message: "‘땡땡’님께 응원을 보냈어요!")
            .padding(.bottom, 40)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray100)
}
