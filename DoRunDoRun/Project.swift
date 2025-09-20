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
                    "NSMotionUsageDescription": "사용자의 움직임 데이터를 측정하기 위해 권한이 필요합니다.",
                    "NSLocationWhenInUseUsageDescription": "위치 기반 지도 기능을 위해 권한이 필요합니다.",
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

