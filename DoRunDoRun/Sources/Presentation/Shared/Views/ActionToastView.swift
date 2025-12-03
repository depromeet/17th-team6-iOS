import SwiftUI

struct ActionToastView: View {
    let message: String
    let icon: Image?
    let iconColor: Color?

    init(message: String, icon: Image? = nil, iconColor: Color? = nil) {
        self.message = message
        self.icon = icon
        self.iconColor = iconColor
    }

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                icon
                    .renderingMode(.template)
                    .foregroundStyle(iconColor ?? Color.red)
            }
            TypographyText(text: message, style: .b1_500, color: .gray0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.dimDark)
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
