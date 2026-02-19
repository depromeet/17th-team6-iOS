//
//  GraphicStyle.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/2/25.
//

enum GraphicStyle: String {
    // MARK: Certification
    case certificationCompleted = "graphic_certification_completed"
    // MARK: - Running
    case runningStart = "graphic_running_start"
    case runningVerified = "graphic_running_verified"
    case runningRecordBanner = "graphic_running_record_banner"
    
    // MARK: - Emoji
    case emojiSurprised = "graphic_emoji_surprised"
    case emojiHeart = "graphic_emoji_heart"
    case emojiFire = "graphic_emoji_fire"
    case emojiThumbsup = "graphic_emoji_thumbsup"
    case emojiCongrats = "graphic_emoji_congrats"
    
    // MARK: - Empty
    case empty1 = "graphic_empty_1"
    case empty2 = "graphic_empty_2"
    
    // MARK: - Error
    case error = "graphic_error_1"
    
    // MARK: - Profile
    case profilePlaceholder = "graphic_profile_placeholder"
    
    // MARK: - Notification
    case notification1 = "graphic_notification_1"
    case notification2 = "graphic_notification_2"
    case notification3 = "graphic_notification_3"
    
    // MARK: - Onboarding
    case onboarding1 = "graphic_onboarding_1"
    case onboarding2 = "graphic_onboarding_2"
    case onboarding3 = "graphic_onboarding_3"
    
    // MARK: - Friend
    case friendMarker = "graphic_friend_marker"
    
    // MARK: - Upload Template
    case uploadTemplate1 = "graphic_upload_template_1"
    case uploadTemplate2 = "graphic_upload_template_2"
    case uploadTemplate3 = "graphic_upload_template_3"
    case uploadTemplate4 = "graphic_upload_template_4"
}

extension GraphicStyle {
    static let uploadTemplates: [GraphicStyle] = [
        .uploadTemplate1,
        .uploadTemplate2,
        .uploadTemplate3,
        .uploadTemplate4
    ]
}
