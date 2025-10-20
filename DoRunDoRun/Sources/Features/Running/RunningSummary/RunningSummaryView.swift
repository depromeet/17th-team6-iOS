import SwiftUI
import ComposableArchitecture

struct RunningSummaryView: View {
    let store: StoreOf<RunningSummaryFeature>
    
    var body: some View {
            VStack(spacing: .zero) {
                Text("2025.10.09 기록")
                    .typography(.h2_700, color: .gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 24)
                
                
                VStack(spacing: 16) {
                    HStack {
                        StatItem(title: "총 달린 거리", value: .prominent("8.02km"))
                        StatItem(title: "총 걸린 시간", value: .prominent("01:52:06"))
                    }
                    
                    HStack {
                        StatItem(title: "평균 페이스", value: .standard("7’30’’"))
                        StatItem(title: "케이던스", value: .standard("144 spm"))
                    }
                }
                .padding(.bottom, 24)
                
                // TODO: 루트가 표현된 지도 이미지로 교체
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(height: 335)
                    .cornerRadius(8)
                    .padding(.bottom, 32)
                
                Button {
                    print("Button action")
                } label: {
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: .zero) {
                            Text("아직 인증을 하지 않았어요!")
                                .typography(.b2_400, color: .gray0)
                            
                            Text("지금 인증 하러 가기")
                                .typography(.t1_700, color: .gray0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // TODO: 캐릭터 이미지로 변경
                        Image("graphic_goal")
                            .resizable()
                            .frame(width: 72, height: 72, alignment: .trailing)   
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background {
                        Color.blue600
                            .cornerRadius(16)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color.gray0)
    }
}

struct StatItem: View {
    enum Value {
        case prominent(String)
        case standard(String)
    }
    
    let title: String
    let value: Value
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(title)
                .typography(.c1_400, color: .gray600)
            
            valueText
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var valueText: some View {
        switch value {
        case .prominent(let text):
            Text(text)
                .typography(.h1_700, color: .gray900)
        case .standard(let text):
            Text(text)
                .typography(.t1_700, color: .gray900)
        }
    }
}

#Preview {
    RunningSummaryView(
        store: Store(
            initialState: RunningSummaryFeature.State(),
            reducer: { RunningSummaryFeature() }
        )
    )
}
