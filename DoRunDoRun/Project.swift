import ProjectDescription

let project = Project(
    name: "DoRunDoRun",
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
                    "UIBackgroundModes": ["location"],
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
            ),
            buildableFolders: [
                "./Sources",
                "./Resources",
            ],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "NMapsMap"),
                .external(name: "Alamofire"),
            ],
            settings: .settings(
                base: [:],
                configurations: [
                    .debug(name: "Debug", xcconfig: "../Configs/Debug.xcconfig"),
                    .release(name: "Release", xcconfig: "../Configs/Release.xcconfig"),
                ]
            ),
        )
    ]
)
