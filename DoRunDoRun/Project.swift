import ProjectDescription

let project = Project(
    name: "DoRunDoRun",
    packages: [
        .remote(url: "https://github.com/pointfreeco/swift-composable-architecture.git", requirement: .branch("main")),
        .remote(url: "https://github.com/navermaps/SPM-NMapsMap", requirement: .branch("main")),
        .remote(url: "https://github.com/Alamofire/Alamofire", requirement: .upToNextMajor(from: "5.8.0")),
        .remote(url: "https://github.com/Moya/Moya.git", requirement: .upToNextMajor(from: "15.0.0")),
        .remote(url: "https://github.com/onevcat/Kingfisher.git", requirement: .upToNextMajor(from: "8.6.0")),
        .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .upToNextMajor(from: "11.5.0")),
    ],
    targets: [
        .target(
            name: "DoRunDoRun",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.dorundorun",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "두런두런",
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "UIUserInterfaceStyle": "Light",
                    "NSLocationWhenInUseUsageDescription": "러닝 중 현재 위치와 이동 경로를 기록하고, 달린 거리를 계산하기 위해 위치 정보가 필요합니다.",
                    "NSMotionUsageDescription": "걸음 수 및 움직임 데이터를 활용해 운동 정보를 정확하게 표시하기 위해 모션 데이터를 사용합니다.",
                    "NSPhotoLibraryAddUsageDescription": "러닝 인증 사진을 앨범에 저장하기 위해 사진 보관함 접근 권한이 필요합니다.",
                    "NSUserNotificationUsageDescription": "친구의 반응, 인증 알림 등 중요한 정보를 빠르게 받아보기 위해 알림 권한이 필요합니다.",

                    "UIBackgroundModes": .array([
                        .string("location"),
                        .string("remote-notification")
                    ]),
                    "NMFNcpKeyId": "$(NMFNcpKeyId)",
                    "BASE_URL": "$(BASE_URL)",
                    "UIAppFonts": .array([
                        .string("Pretendard-Thin.otf"),
                        .string("Pretendard-SemiBold.otf"),
                        .string("Pretendard-Regular.otf"),
                        .string("Pretendard-Medium.otf"),
                        .string("Pretendard-Light.otf"),
                        .string("Pretendard-ExtraLight.otf"),
                        .string("Pretendard-ExtraBold.otf"),
                        .string("Pretendard-Bold.otf"),
                        .string("Pretendard-Black.otf"),
                    ])
                ]
            ), buildableFolders: [
                "./Sources",
                "./Resources",
            ],
            entitlements: "DoRunDoRun.entitlements",
            dependencies: [
                .package(product: "ComposableArchitecture"),
                .package(product: "NMapsMap"),
                .package(product: "Alamofire"),
                .package(product: "Moya"),
                .package(product: "Kingfisher"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseMessaging"),
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": "-ObjC"
                ],
                configurations: [
                    .debug(name: "Debug", xcconfig: "../Configs/Debug.xcconfig"),
                    .release(name: "Release", xcconfig: "../Configs/Release.xcconfig"),
                ]
            ),
        )
    ]
)
