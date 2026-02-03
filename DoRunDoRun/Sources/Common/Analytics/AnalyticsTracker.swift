//
//  AnalyticsTracker.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 1/22/26.
//

import FirebaseAnalytics

final class AnalyticsTracker: AnalyticsTracking {

    func track(_ event: AnalyticsEvent) {

        switch event {

        // MARK: ScreenView
        case .screenViewed(let screen):
            Analytics.logEvent(
                AnalyticsEventScreenView,
                parameters: [
                    AnalyticsParameterScreenName: screen.name,
                    AnalyticsParameterScreenClass: screen.className
                ]
            )

        // MARK: Running
        case .running(let e):
            switch e {
            case .runStarted(let id):
                Analytics.logEvent(
                    "run_started",
                    parameters: ["running_id": id]
                )

            case .runCompleted(let id):
                Analytics.logEvent(
                    "run_completed",
                    parameters: ["running_id": id]
                )
            }

        // MARK: My
        case .my(let e):
            switch e {
            case .sessionSegmentSelected:
                Analytics.logEvent(
                    "session_segment_clicked",
                    parameters: ["segment_name": "session"]
                )

            case .sessionItemSelected(let id):
                Analytics.logEvent(
                    "session_item_selected",
                    parameters: ["session_id": id]
                )
            }

        // MARK: Feed
        case .feed(let e):
            switch e {

            case .createFeedCtaClicked(let source, let runningID):
                var params: [String: Any] = [
                    "source": source.rawValue
                ]
                if let runningID {
                    params["running_id"] = runningID
                }
                Analytics.logEvent(
                    "create_feed_cta_clicked",
                    parameters: params
                )

            case .sessionSelected(let id):
                Analytics.logEvent(
                    "session_selected",
                    parameters: ["session_id": id]
                )

            case .manualInputConfirmed:
                Analytics.logEvent(
                    "manual_input_confirmed",
                    parameters: nil
                )

            case .createFeedEntryCompleted(let runningID, let entryPoint):
                var params: [String: Any] = [
                    "entry_point": entryPoint.rawValue
                ]
                if let runningID {
                    params["running_id"] = runningID
                }
                Analytics.logEvent(
                    "create_feed_entry_completed",
                    parameters: params
                )
                
            case .photoChanged(let source, let size):
                Analytics.logEvent(
                    "create_feed_photo_changed",
                    parameters: [
                        "source": source,
                        "file_size_kb": size
                    ]
                )

            case .uploadClicked(let runningID):
                var params: [String: Any] = [:]
                if let runningID {
                    params["running_id"] = runningID
                }
                Analytics.logEvent(
                    "create_feed_upload_clicked",
                    parameters: params
                )
                
            case .uploadSucceeded(let entryPoint):
                Analytics.logEvent(
                    "create_feed_upload_succeeded",
                    parameters: [
                        "entry_point": entryPoint.rawValue
                    ]
                )

            case .uploadFailed(let errorCode):
                Analytics.logEvent(
                    "create_feed_upload_failed",
                    parameters: [
                        "error_code": errorCode
                    ]
                )
            }

        // MARK: Ad
        case .ad(let e):
            switch e {
            case .adDisplaySucceeded:
                Analytics.logEvent(
                    "ad_display_succeeded",
                    parameters: nil
                )

            case .adDisplayFailed(let errorCode):
                Analytics.logEvent(
                    "ad_display_failed",
                    parameters: ["error_code": errorCode]
                )
            }
        }
    }
}
