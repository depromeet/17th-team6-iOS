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
                ]
            ),
            buildableFolders: [
                "./Sources",
                "./Resources",
            ],
            dependencies: [
            ]
        )
    ]
)
