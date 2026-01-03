//
//  AdBannerView.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 1/3/26.
//

import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    let adUnitID = APIConfig.admobBannerAdUnitID

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView()
        bannerView.adUnitID = adUnitID
        
        // Root ViewController 설정
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        bannerView.adSize = AdSizeBanner
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        let request = Request()
        uiView.load(request)
    }
}

// SwiftUI 래퍼
struct BannerAd: View {
    var body: some View {
        AdBannerView()
            .frame(width: 320, height: 50)
            .background(Color.clear)
    }
}

#Preview {
    BannerAd()
}
