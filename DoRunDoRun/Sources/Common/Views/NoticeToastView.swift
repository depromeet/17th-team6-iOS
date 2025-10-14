import SwiftUI

struct NoticeToastView: View {
    let message: String
    var imageName: String? = nil

    var body: some View {
        HStack(spacing: 16) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .frame(width: 72, height: 72)
            }

            Text(message)
                .typography(.b1_700, color: .gray600)
        }
        .padding(.leading, 8)
        .padding(.trailing, 24)
        .background(Color.gray0)
        .cornerRadius(16)
    }
}

#Preview {
    VStack {
        NoticeToastView(message: "‘수연’님이 응원을 보냈어요!", imageName: "graphic_congrats")
            .padding(.top, 40)
        Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray100)
}
