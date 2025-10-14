import SwiftUI

struct TypographyPreview: View {
    private let styles: [TypographyStyle] = [
        .h1_700, .h2_700, .h3_700, .t1_700,
        .b1_700, .b1_500, .b2_400, .c1_400
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(styles, id: \.self) { style in
                    Text("\(String(describing: style)) → 두런두런, 목표를 향해 달리는")
                        .typography(style, color: .gray900)
                }
            }
            .padding()
        }
    }
}

#Preview {
    TypographyPreview()
}
