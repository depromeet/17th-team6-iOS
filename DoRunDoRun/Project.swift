import ProjectDescription

let project = Project(
    name: "DoRunDoRun",
    targets: [
        .target(
            name: "DoRunDoRun",
            destinations: .iOS,
            product: .app,
            bundleId: "depromeet.seventeen.six",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ],
                            ]
                        ]
                    ],
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "NSLocationWhenInUseUsageDescription": "위치 기반 지도 기능을 위해 권한이 필요합니다.",
                    "UIAppFonts": .array([
                        .string("Pretendard-Thin.ttf"),
                        .string("Pretendard-SemiBold.ttf"),
                        .string("Pretendard-Regular.ttf"),
                        .string("Pretendard-Medium.ttf"),
                        .string("Pretendard-Light.ttf"),
                        .string("Pretendard-ExtraLight.ttf"),
                        .string("Pretendard-ExtraBold.ttf"),
                        .string("Pretendard-Bold.ttf"),
                        .string("Pretendard-Black.ttf"),
                    ])
                ]
            ),
            buildableFolders: [
                "./Sources",
                "./Resources",
            ],
            dependencies: [
              .external(name: "Alamofire"),
              .external(name: "NMapsMap")
            ]
        ),
    ]
)

