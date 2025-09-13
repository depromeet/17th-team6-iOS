import ProjectDescription

let project = Project(
    name: "DoRunDoRun",
    targets: [
        .target(
            name: "DoRunDoRun",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.DoRunDoRun",
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
                ]
            ),
            buildableFolders: [
                "DoRunDoRun/Sources",
                "DoRunDoRun/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "DoRunDoRunTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.DoRunDoRunTests",
            infoPlist: .default,
            buildableFolders: [
                "DoRunDoRun/Tests"
            ],
            dependencies: [.target(name: "DoRunDoRun")]
        ),
    ]
)
