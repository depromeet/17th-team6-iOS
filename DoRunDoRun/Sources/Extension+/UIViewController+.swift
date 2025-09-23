//  UIViewController+.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/24/25.
//

import UIKit

extension UIViewController {
    
    /// 최상단 Window를 찾는 함수 (TabBar까지 완전히 덮기 위해)
    private func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    /// TabBar Controller까지 완전히 덮는 전체 화면 오버레이를 표시하는 함수
    func showFullScreenOverlay(tag: Int = 9999) {
        guard let keyWindow = getKeyWindow() else {
            print("Key Window를 찾을 수 없습니다.")
            return
        }
        
        // 기존 오버레이가 있다면 제거
        keyWindow.subviews.first { $0.tag == tag }?.removeFromSuperview()
        
        // 오버레이 뷰 생성
        let overlayView = UIView()
        overlayView.tag = tag
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.73) // #000000 with 73% opacity
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        // 탭 제스처 추가 (탭하면 오버레이 제거)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(tapGesture)
        
        // Key Window에 직접 추가하여 TabBar까지 완전히 덮음
        keyWindow.addSubview(overlayView)
        
        // 전체 화면을 덮도록 제약 조건 설정 (상태바부터 TabBar까지 모든 영역)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: keyWindow.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor)
        ])
        
        // 페이드 인 애니메이션
        overlayView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            overlayView.alpha = 1
        }
        
        print("TabBar까지 포함한 전체 화면 오버레이가 표시되었습니다.")
    }
    
    /// 오버레이 뷰를 제거하는 함수
    func hideFullScreenOverlay(tag: Int = 9999) {
        guard let keyWindow = getKeyWindow(),
              let overlayView = keyWindow.subviews.first(where: { $0.tag == tag }) else {
            print("제거할 오버레이를 찾을 수 없습니다.")
            return
        }
        
        // 페이드 아웃 애니메이션
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 0
        }) { _ in
            overlayView.removeFromSuperview()
            print("전체 화면 오버레이가 제거되었습니다.")
        }
    }
    
    /// 오버레이 탭 시 호출되는 함수
    @objc private func overlayTapped() {
        hideFullScreenOverlay()
    }
    
    /// TabBar를 포함한 Root View Controller에 오버레이를 추가하는 대안 함수
    func showFullScreenOverlayOnRootView(tag: Int = 9999) {
        guard let keyWindow = getKeyWindow(),
              let rootViewController = keyWindow.rootViewController else {
            print("Root View Controller를 찾을 수 없습니다.")
            return
        }
        
        // 기존 오버레이가 있다면 제거
        rootViewController.view.subviews.first { $0.tag == tag }?.removeFromSuperview()
        
        // 오버레이 뷰 생성
        let overlayView = UIView()
        overlayView.tag = tag
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.73)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTappedOnRoot))
        overlayView.addGestureRecognizer(tapGesture)
        
        // Root View Controller에 추가 (TabBar 포함)
        rootViewController.view.addSubview(overlayView)
        
        // 전체 화면을 덮도록 제약 조건 설정
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor)
        ])
        
        // 페이드 인 애니메이션
        overlayView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            overlayView.alpha = 1
        }
        
        print("Root View에 TabBar까지 포함한 오버레이가 표시되었습니다.")
    }
    
    /// Root View의 오버레이 탭 시 호출되는 함수
    @objc private func overlayTappedOnRoot() {
        hideFullScreenOverlayOnRootView()
    }
    
    /// Root View의 오버레이를 제거하는 함수
    func hideFullScreenOverlayOnRootView(tag: Int = 9999) {
        guard let keyWindow = getKeyWindow(),
              let rootViewController = keyWindow.rootViewController,
              let overlayView = rootViewController.view.subviews.first(where: { $0.tag == tag }) else {
            print("제거할 Root View 오버레이를 찾을 수 없습니다.")
            return
        }
        
        // 페이드 아웃 애니메이션
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 0
        }) { _ in
            overlayView.removeFromSuperview()
            print("Root View 오버레이가 제거되었습니다.")
        }
    }
}
