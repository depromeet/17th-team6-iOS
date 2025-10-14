import SwiftUI

struct ColorPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            colorSection(title: "Primary", colors: [.blue900, .blue800, .blue700, .blue600, .blue500, .blue400, .blue300, .blue200, .blue100])
            colorSection(title: "Secondary", colors: [.lime600])
            colorSection(title: "Grayscale", colors: [.gray900, .gray800, .gray700, .gray600, .gray500, .gray400, .gray300, .gray200, .gray100, .gray50, .gray10, .gray0])
            colorSection(title: "Semantic", colors: [.red, .redLight, .yellow, .green])
        }
        .padding(24)
    }

    private func colorSection(title: String, colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .typography(.h1_700)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(colors, id: \.self) { color in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                            .frame(width: 60, height: 60)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    ColorPreview()
}
