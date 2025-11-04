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
            bundleId: "depromeet.seventeen.six",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "UIUserInterfaceStyle": "Light",
                    "NSLocationWhenInUseUsageDescription": "러닝 중 현재 위치와 이동 경로를 지도에 표시하고, 달린 거리를 계산하기 위해 위치 정보를 사용합니다.",
                    "NSLocationAlwaysAndWhenInUseUsageDescription": "앱이 백그라운드에 있을 때도 러닝 거리와 경로를 정확히 기록하기 위해 위치 정보를 사용합니다.",
                    "NSMotionUsageDescription": "런닝 중 관련 데이터를 표시하기 위해 움직임 정보를 사용합니다.",
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
