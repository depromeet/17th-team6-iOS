//
//  RunningRepositoryProtocol.swift
//  
//
//  Created by zaehorang on 9/13/25.
//

protocol RunningRepositoryProtocol: AnyObject {
    /// 서비스 -> 도메인으로 전달되는 이벤트 스트림
    var onEvent: ((RunningEvent) -> Void)? { get set }
    /// 위치 권한 상태 확인/요청
    func checkAuthorization()
    /// 위치 업데이트 시작
    func startRouteTracking()
    /// 위치 업데이트 정지
    func finishRouteTracking()
}
