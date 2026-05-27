//
//  AppDelegate.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/2/25.
//

import UIKit
import AppTrackingTransparency
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase 설정
        FirebaseApp.configure()

        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()

        // Firebase Messaging 설정
        Messaging.messaging().delegate = self

        // 앱 실행 직후에는 window가 준비되지 않아 ATT 다이얼로그가 무시됨 — 1초 지연 후 요청
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
                    MobileAds.shared.start(completionHandler: nil)
                    InterstitialAdManager.shared.loadAd()
                }
            }
        }

        return true
    }

    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    // 파이어베이스 MessagingDelegate 설정
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("📱 FCM Token:", fcmToken)
        FCMTokenManager.shared.fcmToken = fcmToken
    }
}
