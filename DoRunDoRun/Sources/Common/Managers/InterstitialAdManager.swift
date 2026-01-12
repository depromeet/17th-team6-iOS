//
//  InterstitialAdManager.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 1/6/26.
//

import GoogleMobileAds
import UIKit

final class InterstitialAdManager: NSObject {

    static let shared = InterstitialAdManager()

    private var interstitialAd: InterstitialAd?
    private var onDismiss: (() -> Void)?

    private override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = Request()
        InterstitialAd.load(
            with: APIConfig.admobInterstitialAdUnitID,
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                print("❌ Interstitial load error:", error)
                return
            }
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    func show(from viewController: UIViewController, onDismiss: @escaping () -> Void) {
        guard let ad = interstitialAd else {
            onDismiss()
            loadAd()
            return
        }

        self.onDismiss = onDismiss
        ad.present(from: viewController)
    }
}

extension InterstitialAdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        onDismiss?()
        onDismiss = nil
        loadAd() // 다음 광고 미리 로드
    }

    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Failed to present:", error)
        onDismiss?()
        loadAd()
    }
}
